//
//  PostgreSQLAdapter.m
//  Crate
//
//  Created by Alex Barlow on 11/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "PostgreSQLAdapter.h"

@implementation PostgreSQLAdapter
{
    NSString *connectionURL;
    dispatch_queue_t dbQueue;
    PGconn *conn;
}

+ (NSString *)connectionStringFromDictionary:(NSDictionary*)dict
{
    NSMutableString *connectionString = [NSMutableString stringWithString:@""];
    if (dict[@"host"] != [NSNull null]) {
        [connectionString appendFormat:@"host='%@' ", dict[@"host"]];
    }
    
    if (dict[@"port"] != [NSNull null]) {
        [connectionString appendFormat:@"port='%@' ", dict[@"port"]];
    }
    
    if (dict[@"user"] != [NSNull null]) {
        [connectionString appendFormat:@"user='%@' ", dict[@"user"]];
    }
    
    if (dict[@"password"] != [NSNull null]) {
        [connectionString appendFormat:@"password='%@' ", dict[@"password"]];
    }
    
    if (dict[@"database_name"] != [NSNull null]) {
        [connectionString appendFormat:@"dbname='%@' ", dict[@"database_name"]];
    }
    
    return [connectionString copy];
}

- (void)connectWithConnectionString:(NSString *)connectionString
                      dispatchQueue:(dispatch_queue_t)dispatchQueue
                            success:(void (^)(id <DBConnection> connection))success
                            failure:(void (^)(NSString *error))failure
{
    connectionURL = connectionString;
    dbQueue = dispatchQueue;
    
    dispatch_async(dispatchQueue, ^{
        conn = PQconnectdb([connectionURL UTF8String]);
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

- (void)execQuery:(NSString *)query
          success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
          failure:(void (^)(NSString *error))failure
{
    dispatch_async(dbQueue, ^{
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        PGresult *res = PQexec(conn, [query UTF8String]);
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        
        if (PQresultStatus(res) != PGRES_BAD_RESPONSE || PQresultStatus(res) != PGRES_FATAL_ERROR) {
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

-(void)availableDatabasesWithSuccess:(void (^)(NSArray *databases))success
                             failure:(void (^)(NSString *))failure
{
    [self execQuery:@"SELECT datname FROM pg_database WHERE datistemplate = false"
            success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
                success([resultSet allResults]);
            }
            failure:^(NSString *error) {
                failure(error);
            }];
}

-(BOOL)isOpen
{
    return (BOOL)(PQstatus(conn) == CONNECTION_OK);
}

-(void)close
{
    PQfinish(conn);
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
    return PQfnumber(res, [identifier UTF8String]);
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
