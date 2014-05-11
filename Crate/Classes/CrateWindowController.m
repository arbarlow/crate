//
//  CrateWindowController.m
//  Crate
//
//  Created by Alex Barlow on 06/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "CrateWindowController.h"
#import "PostgreSQLAdapter.h"

@interface CrateWindowController ()

@end

@implementation CrateWindowController
{
    dispatch_queue_t dbQueue;
    ConnectViewController *connectController;
    ConnectionViewController *connectionController;
    id <DBConnection> dbConnection;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    connectController    = [[ConnectViewController alloc] initWithNibName:@"ConnectViewController" bundle:nil];
    connectionController = [[ConnectionViewController alloc] init];
    connectController.delegate = self;
    self.window.contentView = connectController.view;
    
    NSString *queueName = [NSString stringWithFormat:@"com.cratedb.window-%d", (int)self.window.windowNumber];
    dbQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
}

-(void)connectWithDictionary:(NSDictionary*)dict
{
    NSString *connectionString = [PostgreSQLAdapter connectionStringFromDictionary:dict];
    dbConnection = [[PostgreSQLAdapter alloc] init];
    [dbConnection connectWithConnectionString:connectionString
                                dispatchQueue:dbQueue
                                      success:^(id<DBConnection> connection) {
                                          connectionController.dbConnection = connection;
                                          self.window.contentView = connectionController.view;
                                      } failure:^(NSString *error) {
                                          NSLog(@"error connecting %@", error);
                                      }];
}

@end
