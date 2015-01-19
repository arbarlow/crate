//
//  SchemaViewController.m
//  Crate
//
//  Created by Alex Barlow on 28/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "SchemaViewController.h"

@interface SchemaViewController ()

@end

@implementation SchemaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)loadView{
    [super loadView];

    _columnResultsController = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
    _indexesResultsController = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
    [self.view replaceSubview:[self.view.subviews firstObject] with:_columnResultsController.view];
    [self.view replaceSubview:[self.view.subviews lastObject] with:_indexesResultsController.view];
    
    [_columnResultsController.view setFocusRingType:NSFocusRingTypeNone];
    [_indexesResultsController.view setFocusRingType:NSFocusRingTypeNone];
}

-(void)displaySchema:(NSString*)tableName
{
    [_dbConnection schemaForTable:tableName success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
        [_columnResultsController displayResults:resultSet];
    } failure:^(NSString *error) {
        [ErrorView displayForView:[_columnResultsController.view.subviews lastObject]
                            title:@"Schema loading"
                          message:error];
    }];
    
    [_dbConnection indexesForTable:tableName success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
        [_indexesResultsController displayResults:resultSet];
    } failure:^(NSString *error) {
        [ErrorView displayForView:[_indexesResultsController.view.subviews lastObject]
                            title:@"Schema loading"
                          message:error];
    }];
}

@end
