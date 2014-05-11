//
//  DBConnection.h
//  Crate
//
//  Created by Alex Barlow on 10/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBConnection;
@protocol DBDatabase;
@protocol DBResultSet;

@protocol DBConnection <NSObject>

@property (readonly) id <DBDatabase> database;

+ (NSString *)name;
- (void)connectWithConnectionString:(NSString *)url
                      dispatchQueue:(dispatch_queue_t)dispatchQueue
                            success:(void (^)(id <DBConnection> connection))success
                            failure:(void (^)(NSString *error))failure;
- (void)close;
- (BOOL)isOpen;
- (NSString *)description;
- (void)execQuery:(NSString *)query
          success:(void (^)(id <DBResultSet> resultSet, NSTimeInterval elapsedTime))success
          failure:(void (^)(NSString *error))failure;
- (void)availableDatabasesWithSuccess:(void (^)(NSArray *databases))success
                              failure:(void (^)(NSString *error))failure;

@end

#pragma mark -

@protocol DBDatabase <NSObject>

@property (readonly) id <DBConnection> connection;
@property (readonly) NSString *name;

- (NSArray*)tables;

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