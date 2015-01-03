//
//  PostgreSQLAdapaterTests.m
//  Crate
//
//  Created by Alex Barlow on 20/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCTAsyncTestCase/XCTAsyncTestCase.h>
#import "MySQLAdapter.h"

#define DEFAULT_CONNECT @{@"user": @"root", @"database_name": @"crate_test"}

@interface MySQLAdapterTests : XCTAsyncTestCase
@end

@implementation MySQLAdapterTests {
    dispatch_queue_t dbQueue;
    MySQLAdapter *dbConnection;
}

- (void)setUp
{
    [super setUp];
    
    if (!dbQueue) {
        dbQueue = dispatch_queue_create("com.cratedb.tests", DISPATCH_QUEUE_SERIAL);
    }
    
    if (!dbConnection) {
        dbConnection = [[MySQLAdapter alloc] init];
    }
}

- (void)tearDown
{
    [super tearDown];
}

-(void)defaultConnectWithSuccess:(void (^)(id <DBConnection> connection))success
{
    [dbConnection connectWithDictionary:DEFAULT_CONNECT
                          dispatchQueue:dbQueue
                                success:success
                                failure:^(NSString *error) {
                                    NSLog(@"Could not connect to MySQL with DEFAULT_CONNECT");
                                    [self notify:kXCTUnitWaitStatusFailure];
                                }];
}

- (void)testConnectSuccess
{
    [self prepare];

    [dbConnection connectWithDictionary:DEFAULT_CONNECT dispatchQueue:dbQueue success:^(id<DBConnection> connection) {
        [self notify:kXCTUnitWaitStatusSuccess];
    } failure:^(NSString *error) {
        [self notify:kXCTUnitWaitStatusFailure];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testIsOpen
{
    [self prepare];
    
    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        if ([connection isOpen]) {
            [self notify:kXCTUnitWaitStatusSuccess];
        } else {
            [self notify:kXCTUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testClose
{
    [self prepare];
    
    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        [connection close];
        if (![connection isOpen]) {
            [self notify:kXCTUnitWaitStatusSuccess];
        } else {
            [self notify:kXCTUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testConnectFailure
{
    [self prepare];
    
    NSDictionary *connectionDict = @{@"database_name": @"databaseThatDoesntExist"};
    [dbConnection connectWithDictionary:connectionDict dispatchQueue:dbQueue success:^(id<DBConnection> connection) {
        [self notify:kXCTUnitWaitStatusSuccess];
    } failure:^(NSString *error) {
        [self notify:kXCTUnitWaitStatusFailure];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusFailure timeout:2.0];
}

- (void)testSelectDatabase
{
    [self prepare];
    
    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        [dbConnection selectDatabase:@"information_schema" success:^(id<DBConnection> connection) {
            [self notify:kXCTUnitWaitStatusSuccess];
        } failure:^(NSString *error) {
            NSLog(@"Error selecting DB %@", error);
            [self notify:kXCTUnitWaitStatusFailure];
        }];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testAvailableDatabases
{
    [self prepare];
    
    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        [dbConnection availableDatabasesWithSuccess:^(NSArray *databases, NSString *currentDatabase) {
            if ([databases indexOfObject:@"crate_test"] != NSNotFound) {
                [self notify:kXCTUnitWaitStatusSuccess];
            } else {
                [self notify:kXCTUnitWaitStatusFailure];
            }
        } failure:^(NSString *error) {
            [self notify:kXCTUnitWaitStatusFailure];
        }];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testAvailableTables
{
    [self prepare];
    
    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        [dbConnection tablesForDatabaseWithSuccess:^(NSArray *tables) {
            if ([tables count] == 6) {
                [self notify:kXCTUnitWaitStatusSuccess];
            } else {
                [self notify:kXCTUnitWaitStatusFailure];
            }
        } failure:^(NSString *error) {
            [self notify:kXCTUnitWaitStatusFailure];
        }];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:2.0];
}

- (void)testBadSQLExec
{
    [self prepare];

    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        [dbConnection execQuery:@"this isnt a query()" success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
            [self notify:kXCTUnitWaitStatusSuccess];
        } failure:^(NSString *error) {
            [self notify:kXCTUnitWaitStatusFailure];
        }];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusFailure timeout:2.0];
}

# pragma mark -

-(void)testResultSet
{
    [self prepare];
    
    [self defaultConnectWithSuccess:^(id<DBConnection> connection) {
        [dbConnection execQuery:@"SELECT * FROM employees ORDER BY first_name LIMIT 100" success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
            
            if ([resultSet numberOfFields] == 6 &&
                [resultSet numberOfRecords] == 100 &&
                [resultSet indexForFieldWithIdentifier:@"emp_no"] == 0 &&
                [[resultSet identifierForFieldAtIndex:0] isEqualToString:@"emp_no"] &&
                [[resultSet valueAtRecordIndex:0 forFieldIndex:0] isEqualToString:@"86639"])
            {
                [self notify:kXCTUnitWaitStatusSuccess];
            } else {
                [self notify:kXCTUnitWaitStatusFailure];
            }
        } failure:^(NSString *error) {
            [self notify:kXCTUnitWaitStatusFailure];
        }];
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:4.0];
}

@end
