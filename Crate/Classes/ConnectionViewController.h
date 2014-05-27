//
//  ConnectionViewController.h
//  Crate
//
//  Created by Alex Barlow on 10/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConnectionViewController : NSViewController <NSTableViewDelegate>

@property (nonatomic, strong) id <DBConnection> dbConnection;
@property (weak) IBOutlet NSTableView *tablesTableView;
@property (nonatomic, strong) NSMutableArray *tables;

-(void)displayTables;

@end
