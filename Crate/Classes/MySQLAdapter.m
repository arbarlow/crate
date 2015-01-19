//
//  MySQLAdapter.m
//  Crate
//
//  Created by Alex Barlow on 03/01/2015.
//  Copyright (c) 2015 Alex Barlow. All rights reserved.
//

#import "MySQLAdapter.h"

#define DATABASES_QUERY @"SHOW DATABASES"

#define TABLES_QUERY @"SHOW TABLES"

#define SCHEMA_QUERY(table) [NSString stringWithFormat:@"SHOW FULL COLUMNS FROM %@", table]

#define INDEXES_FOR_TABLE(table) [NSString stringWithFormat:@"SHOW INDEXES FROM %@", table]

@implementation MySQLAdapter
{
    NSDictionary *connectionDict;
    dispatch_queue_t dbQueue;
    MYSQL *conn;
}

- (void)connectWithDictionary:(NSDictionary *)connectionDictionary
                dispatchQueue:(dispatch_queue_t)dispatchQueue
                      success:(void (^)(id <DBConnection> connection))success
                      failure:(void (^)(NSString *error))failure
{
    connectionDict = connectionDictionary;
    dbQueue = dispatchQueue;
    
    dispatch_async(dispatchQueue, ^{
        conn = mysql_init(NULL);
        if (!mysql_real_connect(conn,
                                !NullOrNil(connectionDictionary[@"host"]) ? [connectionDictionary[@"host"] UTF8String] : NULL,
                                !NullOrNil(connectionDictionary[@"user"]) ? [connectionDictionary[@"user"] UTF8String] : NULL,
                                !NullOrNil(connectionDictionary[@"password"]) ? [connectionDictionary[@"password"] UTF8String] : NULL,
                                !NullOrNil(connectionDictionary[@"database_name"]) ? [connectionDictionary[@"database_name"] UTF8String] : NULL,
                                NullOrNil(connectionDictionary[@"port"]) ? 0 : (int)[connectionDictionary[@"port"] integerValue], NULL, 0)) {
            failure(NSStringFromChar(mysql_error(conn)));
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(self);
            });
        }
    });
}

- (void)selectDatabase:(NSString*)database
               success:(void (^)(id <DBConnection> connection))success
               failure:(void (^)(NSString *error))failure
{
    [self close];
    NSMutableDictionary *mutableConnection = [connectionDict mutableCopy];
    [mutableConnection setObject:database forKey:@"database_name"];
    
    [self connectWithDictionary:mutableConnection
                  dispatchQueue:dbQueue
                        success:success
                        failure:failure];
}

- (void)execQuery:(NSString *)query
          success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
          failure:(void (^)(NSString *error))failure
{
    dispatch_async(dbQueue, ^{
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        int res = mysql_query(conn, [query UTF8String]);
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        
        // MySQL uses 0 for success and 1 for error, go fucking figure
        if (!res) {
            
            MYSQL_RES *mysql_res = mysql_store_result(conn);
            MySQLResultSet *resultSet = [[MySQLResultSet alloc] initWithResult:mysql_res];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(resultSet, endTime - startTime);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(NSStringFromChar(mysql_error(conn)));
            });
        }
    });
}

-(void)availableDatabasesWithSuccess:(void (^)(NSArray *databases, NSString *currentDatabase))success
                             failure:(void (^)(NSString *))failure
{
    [self execQuery:DATABASES_QUERY
            success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
                NSMutableArray *dbs = [[resultSet allResults] mutableCopy];
                if ([dbs count] > 0) {
                    [dbs removeObjectAtIndex:0];
                }
                
                [self execQuery:@"SELECT DATABASE()"
                        success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
                            success(dbs, [[resultSet allResults] lastObject]);
                        }
                        failure:^(NSString *error) {
                            failure(error);
                        }];
            }
            failure:^(NSString *error) {
                failure(error);
            }];
}

- (void)tablesForDatabaseWithSuccess:(void (^)(NSArray *tables))success
                             failure:(void (^)(NSString *error))failure
{
    [self execQuery:TABLES_QUERY success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
        NSArray *dbs = [resultSet allResults];
        NSMutableArray *dbObjects = [NSMutableArray array];
        
        if ([dbs count] > 0) {
            for (NSString *tableName in dbs) {
                MySQLTable *tableObject = [[MySQLTable alloc] initWithName:tableName];
                [dbObjects addObject:tableObject];
            }
            [dbObjects removeObjectAtIndex:0];
        }
        
        success(dbObjects);
    } failure:^(NSString *error) {
        failure(error);
    }];
}

- (void)schemaForTable:(NSString*)tableName
               success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
               failure:(void (^)(NSString *error))failure
{
    [self execQuery:SCHEMA_QUERY(tableName) success:success failure:failure];
}

- (void)indexesForTable:(NSString*)tableName
                success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
                failure:(void (^)(NSString *error))failure
{
    [self execQuery:INDEXES_FOR_TABLE(tableName) success:success failure:failure];
}

-(BOOL)isOpen
{
    return !mysql_ping(conn);
}

-(void)close
{
    if (conn != nil) {
        mysql_close(conn);
    }
}

// TODO nicely
- (NSString *)description
{
    return @"MySQL";
}

+ (NSString *)name
{
    return @"MySQL";
}

@end

@implementation MySQLTable
{
    NSString *name;
}

-(id)initWithName:(NSString*)tableName
{
    name = tableName;
    return self;
}

- (NSString *)name
{
    return name;
}

@end

@implementation MySQLResultSet
{
    MYSQL_RES *res;
}

-(id)initWithResult:(MYSQL_RES*)result
{
    self = [super init];
    if (!self) {
        return nil;
    }
    res = result;
    return self;
}

- (NSArray*)allResults
{
    int nFields;
    int i,j;
    NSMutableArray *results = [NSMutableArray array];
    
    nFields = mysql_num_fields(res);
    for (i = 0; i < nFields; i++) {
        [results addObject:NSStringFromChar(mysql_fetch_field_direct(res, i)->name)];
    }
    
    MYSQL_ROW row;
    while ((row = mysql_fetch_row(res)))
    {
        for(j = 0; j < nFields; j++) {
            if (row[j] != nil) {
                [results addObject:NSStringFromChar(row[j])];
            }
        }
    }
    
    return [results copy];
}

#pragma mark - Fields

- (NSUInteger)numberOfFields
{
    if (res == nil) {
        return 0;
    } else {
        return mysql_num_fields(res);
    }
}

- (NSString *)identifierForFieldAtIndex:(NSUInteger)index
{
    return NSStringFromChar(mysql_fetch_field_direct(res, (int)index)->name);
}

- (NSUInteger)indexForFieldWithIdentifier:(NSString*)identifier
{
    unsigned int num_fields;
    unsigned int i;
    MYSQL_FIELD *fields;
    
    num_fields = mysql_num_fields(res);
    fields = mysql_fetch_fields(res);
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
    
    for(i = 0; i < num_fields; i++)
    {
        [fieldsArray addObject:NSStringFromChar(fields[i].name)];
    }
    
    NSUInteger idx = [fieldsArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString*)obj isEqualToString:identifier]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    return idx;
}

#pragma mark - Records

- (NSUInteger)numberOfRecords
{
    if (res == nil) {
        return 0;
    } else {
        return mysql_num_rows(res);
    }
}

- (NSString *)valueAtRecordIndex:(NSInteger)index forFieldIndex:(NSInteger)fieldIndex
{
    mysql_data_seek(res, index);
    MYSQL_ROW row = mysql_fetch_row(res);
    if (row[fieldIndex] != nil) {
        return NSStringFromChar(row[fieldIndex]);
    } else {
        return nil;
    }
    
}

#pragma mark -

- (void)dealloc {
    if (res) {
        mysql_free_result(res);
        res = NULL;
    }
}



@end
