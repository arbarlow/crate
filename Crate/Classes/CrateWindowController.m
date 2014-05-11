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
    
    _connectController = [[ConnectViewController alloc] initWithNibName:@"ConnectViewController" bundle:nil];
    _connectController.delegate = self;
    self.window.contentView = _connectController.view;
    
    _connectionController = [[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil];
    
    dispatch_queue_t dbQueue = dispatch_queue_create("mydbqueue", DISPATCH_QUEUE_SERIAL);
    
    id <DBConnection> dbConnection = [[PostgreSQLAdapter alloc] init];
    [dbConnection connectWithConnectionString:@"dbname=postgres" dispatchQueue:dbQueue success:^(id<DBConnection> connection) {
        NSLog(@"connected");
        [dbConnection availableDatabasesWithSuccess:^(NSArray *databases) {
            NSLog(@"databases %@", databases);
        } failure:^(NSString *error) {
            NSLog(@"fail %@", error);
        }];
    } failure:^(NSString *error) {
        NSLog(@"connection failed %@", error);
    }];
}

-(void)connectWithFavourite:(Favourite*)favourite
{
    self.window.contentView = _connectionController.view;
}

@end
