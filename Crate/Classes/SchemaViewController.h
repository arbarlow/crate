//
//  SchemaViewController.h
//  Crate
//
//  Created by Alex Barlow on 28/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResultsViewController.h"

@interface SchemaViewController : NSViewController

@property (nonatomic, strong) id<DBConnection> dbConnection;
@property (nonatomic, strong) ResultsViewController *columnResultsController;
@property (nonatomic, strong) ResultsViewController *indexesResultsController;

@property (weak) IBOutlet NSView *columnsView;


-(void)displaySchema:(NSString*)tableName;

@end
