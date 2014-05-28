//
//  CrateWindowController.m
//  Crate
//
//  Created by Alex Barlow on 06/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "CrateWindowController.h"
#import "PostgreSQLAdapter.h"
#import "INAppStoreWindow.h"

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
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    INAppStoreWindow *aWindow = (INAppStoreWindow*)self.window;
    aWindow.titleBarHeight = 40.0;
    
    [aWindow setCenterFullScreenButton:YES];
    [aWindow setFullScreenButtonRightMargin:10];
    
    self.titleView.frame = aWindow.titleBarView.bounds;
    self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [aWindow.titleBarView addSubview:self.titleView];
    
    connectController    = [[ConnectViewController alloc] initWithNibName:@"ConnectViewController" bundle:nil];
    connectionController = [[ConnectionViewController alloc] initWithNibName:@"ConnectionViewController" bundle:nil];
    connectController.delegate = self;
    self.window.contentView = connectController.view;
    
    NSString *queueName = [NSString stringWithFormat:@"com.cratedb.window-%d", (int)self.window.windowNumber];
    dbQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
}

-(void)connectWithDictionary:(NSDictionary*)dict
{
    [self.progress startAnimation:nil];

    dbConnection = [[PostgreSQLAdapter alloc] init];
    [dbConnection connectWithDictionary:dict
                          dispatchQueue:dbQueue
                                success:^(id<DBConnection> connection) {
                                    connectionController.dbConnection = connection;
                                    self.window.contentView = connectionController.view;
                                    [self setupDatabaseSelect];
                                    [_viewSelector setEnabled:YES];
                                    [connectionController displayTables];
                                } failure:^(NSString *error) {
                                    [connectController displayError:error];
                                    [self.progress stopAnimation:nil];
                                }];
}

-(void)setupDatabaseSelect
{
    [dbConnection availableDatabasesWithSuccess:^(NSArray *databases, NSString *currentDatabase) {
        NSMenu *menu = _databaseSelectButton.menu;
        [menu removeAllItems];
        
        NSMenuItem *selectedItem;
        for (NSString *db in databases) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:db
                                                              action:@selector(didSelectDatabase:)
                                                       keyEquivalent:@""];
            [menu addItem:menuItem];
            
            if ([db isEqualToString:currentDatabase]) {
                selectedItem = menuItem;
            }
        }
        
        if (selectedItem) {
            [_databaseSelectButton selectItem:selectedItem];
        }
        
        [_databaseSelectButton setEnabled:YES];
        
        [self.progress stopAnimation:nil];
    } failure:^(NSString *error) {}];
}

- (IBAction)didSelectView:(id)sender {
    [connectionController didSwitchView:[(NSSegmentedControl*)sender selectedSegment]];
}

-(void)didSelectDatabase:(id)sender
{
    [self.progress startAnimation:nil];
    
    NSString *db = [(NSMenuItem*)sender title];
    [dbConnection selectDatabase:db success:^(id<DBConnection> connection) {
        [connectionController displayTables];
        [self.progress stopAnimation:nil];
    } failure:^(NSString *error) {
        // Handle error
        [self.progress stopAnimation:nil];
    }];
}

@end
