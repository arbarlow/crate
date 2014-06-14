//
//  ResultsViewController.h
//  Crate
//
//  Created by Alex Barlow on 14/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ResultsViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) id <DBResultSet> results;

-(void)displayResults:(id <DBResultSet>)results;

@end
