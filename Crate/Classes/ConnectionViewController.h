//
//  ConnectionViewController.h
//  Crate
//
//  Created by Alex Barlow on 10/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SchemaViewController.h"
#import "BasicDataViewController.h"
#import "QueryViewController.h"

@interface ConnectionViewController : NSViewController <NSTableViewDelegate>

@property (nonatomic, strong) id <DBConnection> dbConnection;
@property (nonatomic, strong) NSMutableArray *tables;
@property (weak) IBOutlet NSTableView *tablesTableView;
@property (weak) IBOutlet NSView *rightHandView;

@property (nonatomic, strong) SchemaViewController *schemaView;
@property (nonatomic, strong) BasicDataViewController *basicDataView;
@property (nonatomic, strong) QueryViewController *queryView;

-(void)displayTables;
-(void)didSwitchView:(NSInteger)viewSelected;

@end
