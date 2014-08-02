//
//  PostgreSQLAdapter.m
//  Crate
//
//  Created by Alex Barlow on 11/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "PostgreSQLAdapter.h"

#define DATABASES_QUERY @"SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname ASC"
#define TABLES_QUERY @"\
SELECT table_name \
FROM information_schema.tables \
WHERE table_type = 'BASE TABLE' \
AND table_schema = 'public' \
ORDER BY table_type, table_name"
#define SCHEMA_QUERY(table) [NSString stringWithFormat:@"\
SELECT column_name, udt_name, data_type, column_default, is_nullable, \
       character_maximum_length, numeric_precision, collation_schema, collation_name \
from INFORMATION_SCHEMA.COLUMNS where table_name = '%@'", table]

@implementation PostgreSQLAdapter
{
    NSDictionary *connectionDict;
    dispatch_queue_t dbQueue;
    PGconn *conn;
}

- (void)connectWithDictionary:(NSDictionary *)connectionDictionary
                dispatchQueue:(dispatch_queue_t)dispatchQueue
                      success:(void (^)(id <DBConnection> connection))success
                      failure:(void (^)(NSString *error))failure
{
    connectionDict = connectionDictionary;
    dbQueue = dispatchQueue;
    
    [self connectWithConnectionString:[self connectionStringFromDictionary:connectionDict]
                        dispatchQueue:dispatchQueue
                              success:success
                              failure:failure];
    
}

- (void)connectWithConnectionString:(NSString *)connectionString
                      dispatchQueue:(dispatch_queue_t)dispatchQueue
                            success:(void (^)(id <DBConnection> connection))success
                            failure:(void (^)(NSString *error))failure
{
    dispatch_async(dispatchQueue, ^{
        conn = PQconnectdb([connectionString UTF8String]);
        if (PQstatus(conn) == CONNECTION_OK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(self);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(NSStringFromChar(PQerrorMessage(conn)));
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
    // Terminate SQL so errors are raised with bad SQL
    query = [query stringByAppendingString:@";"];
    
    // Exec the query
    dispatch_async(dbQueue, ^{
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        PGresult *res = PQexec(conn, [query UTF8String]);
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        
        if (PQresultStatus(res) == PGRES_COMMAND_OK || PQresultStatus(res) == PGRES_TUPLES_OK) {
            PostgreSQLResultSet *resultSet = [[PostgreSQLResultSet alloc] initWithResult:res];
            dispatch_async(dispatch_get_main_queue(), ^{
                success(resultSet, endTime - startTime);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(NSStringFromChar(PQresultErrorMessage(res)));
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
                
                [self execQuery:@"SELECT current_database()"
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
                PostgreSQLTable *tableObject = [[PostgreSQLTable alloc] initWithName:tableName];
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

- (NSString *)connectionStringFromDictionary:(NSDictionary*)dict
{
    NSMutableString *connectionString = [NSMutableString stringWithString:@""];
    if (!NullOrNil(dict[@"host"])) {
        [connectionString appendFormat:@"host='%@' ", dict[@"host"]];
    }
    
    if (!NullOrNil(dict[@"port"])) {
        [connectionString appendFormat:@"port='%@' ", dict[@"port"]];
    }
    
    if (!NullOrNil(dict[@"user"])) {
        [connectionString appendFormat:@"user='%@' ", dict[@"user"]];
    }
    
    if (!NullOrNil(dict[@"password"])) {
        [connectionString appendFormat:@"password='%@' ", dict[@"password"]];
    }
    
    if (!NullOrNil(dict[@"database_name"])) {
        [connectionString appendFormat:@"dbname='%@' ", dict[@"database_name"]];
    }
    
    return [connectionString copy];
}

-(BOOL)isOpen
{
    return (BOOL)(PQstatus(conn) == CONNECTION_OK);
}

-(void)close
{
    if (conn != nil) {
        PQfinish(conn);
    }
}

// TODO nicely
- (NSString *)description
{
    return @"PostgreSQL";
}

+ (NSString *)name
{
    return @"PostgreSQL";
}

@end

@implementation PostgreSQLTable
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

@implementation PostgreSQLResultSet
{
    PGresult *res;
}

-(id)initWithResult:(PGresult*)result
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
    
    nFields = PQnfields(res);
    for (i = 0; i < nFields; i++) {
        [results addObject:NSStringFromChar(PQfname(res, i))];
    }

    for (i = 0; i < PQntuples(res); i++)
    {
        for (j = 0; j < nFields; j++) {
            [results addObject:NSStringFromChar(PQgetvalue(res, i, j))];
        }
    }
    
    return [results copy];
}

#pragma mark - Fields

- (NSUInteger)numberOfFields
{
    return PQnfields(res);
}

- (NSString *)identifierForFieldAtIndex:(NSUInteger)index
{
    return NSStringFromChar(PQfname(res, (int)index));
}

- (NSUInteger)indexForFieldWithIdentifier:(NSString*)identifier
{
    NSString *fieldID = [NSString stringWithFormat:@"\"%@\"", identifier];
    return PQfnumber(res, [fieldID UTF8String]);
}

#pragma mark - Records

- (NSUInteger)numberOfRecords
{
    return PQntuples(res);
}

- (NSString *)valueAtRecordIndex:(NSInteger)index forFieldIndex:(NSInteger)fieldIndex
{
    return NSStringFromChar(PQgetvalue(res, (int)index, (int)fieldIndex));
}

#pragma mark -

- (void)dealloc {
    if (res) {
        PQclear(res);
        res = NULL;
    }
}

@end
