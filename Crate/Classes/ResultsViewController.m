//
//  ResultsViewController.m
//  Crate
//
//  Created by Alex Barlow on 14/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)displayResults:(id <DBResultSet>)results
{
    _results = results;
    [self setupColumns];
    [_tableView reloadData];
}

-(void)setupColumns
{
    for (NSTableColumn *column in [[_tableView tableColumns] copy]) {
        [_tableView removeTableColumn:column];
    }
    
    for (int i=0; i < (int)[_results numberOfFields]; i++) {
        NSString *fieldName = [_results identifierForFieldAtIndex:i];
        
        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%d", i]];
        [tableColumn.headerCell setStringValue:fieldName];
        [_tableView addTableColumn:tableColumn];
    }
    
    for (int i=0; i < (int)[_results numberOfFields]; i++) {
        
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_results numberOfRecords];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSUInteger fieldIndex = [tableColumn.identifier integerValue];
    id result = [_results valueAtRecordIndex:row forFieldIndex:fieldIndex];
    
    if ([result isEqualToString:@""] || result == nil) {
        result = [[NSMutableAttributedString alloc] initWithString:@"NULL" attributes:@{NSForegroundColorAttributeName: [NSColor lightGrayColor]}];
    }
    return result;
}

@end
