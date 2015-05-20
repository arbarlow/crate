//
//  ResultsViewController.m
//  Crate
//
//  Created by Alex Barlow on 14/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "ResultsViewController.h"

#define MAX_COLUMN_WIDTH 230
#define COLUMN_PADDING 10

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
    [self sizeColumns];
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
}

-(void)sizeColumns
{
    NSRect rect = NSMakeRect(0,0, INFINITY, _tableView.rowHeight);
    [_tableView.tableColumns enumerateObjectsUsingBlock:^(id column, NSUInteger idx, BOOL *stop) {
        CGFloat currentSize = 0;
        for (NSInteger i = 0; i < _tableView.numberOfRows; i++) {
            NSCell *cell = [_tableView preparedCellAtColumn:idx row:i];
            NSSize size = [cell cellSizeForBounds:rect];
            if (size.width < MAX_COLUMN_WIDTH) {
                currentSize = MAX(size.width + COLUMN_PADDING, currentSize);
            } else {
                currentSize = MAX_COLUMN_WIDTH;
            }
        }
        if (currentSize < [column width]) {
            currentSize = [column width] + COLUMN_PADDING;
        }
        [column setWidth:currentSize];
    }];
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
