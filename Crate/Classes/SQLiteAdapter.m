//
//  SQLiteAdapter.m
//  Crate
//
//  Created by Alex Barlow on 22/01/2015.
//  Copyright (c) 2015 Alex Barlow. All rights reserved.
//

#import "SQLiteAdapter.h"

@implementation SQLiteAdapter
{
    NSDictionary *connectionDict;
    dispatch_queue_t dbQueue;
    sqlite3 *conn;
}

- (void)connectWithDictionary:(NSDictionary *)connectionDictionary
                dispatchQueue:(dispatch_queue_t)dispatchQueue
                      success:(void (^)(id <DBConnection> connection))success
                      failure:(void (^)(NSString *error))failure
{
    connectionDict = connectionDictionary;
    dbQueue = dispatchQueue;
    
    dispatch_async(dispatchQueue, ^{
        int res = sqlite3_open([connectionDict[@"host"] UTF8String], &conn);
        if (res == SQLITE_OK) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(self);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(NSStringFromChar(sqlite3_errmsg(conn)));
            });
        }
    });
}

@end

@implementation SQLiteTable
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

@implementation SQLiteResultSet

@end
