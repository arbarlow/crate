//
//  DBConnection.h
//  Crate
//
//  Created by Alex Barlow on 10/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBConnection;
@protocol DBResultSet;

@protocol DBConnection <NSObject>

+ (NSString *)name;
- (void)close;
- (BOOL)isOpen;
- (NSString *)description;

- (void)connectWithDictionary:(NSDictionary *)connectionDict
                dispatchQueue:(dispatch_queue_t)dispatchQueue
                      success:(void (^)(id <DBConnection> connection))success
                      failure:(void (^)(NSString *error))failure;

- (void)execQuery:(NSString *)query
          success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
          failure:(void (^)(NSString *error))failure;

- (void)availableDatabasesWithSuccess:(void (^)(NSArray *databases, NSString *currentDatabase))success
                              failure:(void (^)(NSString *error))failure;

- (void)tablesForDatabaseWithSuccess:(void (^)(NSArray *tables))success
                              failure:(void (^)(NSString *error))failure;

- (void)schemaForTable:(NSString*)tableName
               success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
               failure:(void (^)(NSString *error))failure;

- (void)indexesForTable:(NSString*)tableName
                success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
                failure:(void (^)(NSString *error))failure;
@optional

- (void)selectDatabase:(NSString*)database
               success:(void (^)(id <DBConnection> connection))success
               failure:(void (^)(NSString *error))failure;

@end

@protocol DBTable <NSObject>
-(NSString*)name;
@end

#pragma mark -

@protocol DBResultSet <NSObject>

- (NSUInteger)numberOfFields;
- (NSString *)identifierForFieldAtIndex:(NSUInteger)index;
- (NSUInteger)indexForFieldWithIdentifier:(NSString*)identifier;

- (NSUInteger)numberOfRecords;
- (NSString *)valueAtRecordIndex:(NSInteger)index forFieldIndex:(NSInteger)fieldIndex;

- (NSArray*)allResults;

@end