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
        _resultsController = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
        self.view = _resultsController.view;
    }
    return self;
}

-(void)displaySchema:(NSString*)tableName
{
    [_dbConnection schemaForTable:tableName success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
        [_resultsController displayResults:resultSet];
    } failure:^(NSString *error) {
        [ErrorView displayForView:[_resultsController.view.subviews lastObject]
                            title:@"Schema loading"
                          message:error];
    }];
}

@end
