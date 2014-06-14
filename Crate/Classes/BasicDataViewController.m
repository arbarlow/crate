//
//  DataViewController.m
//  Crate
//
//  Created by Alex Barlow on 28/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "BasicDataViewController.h"

@interface BasicDataViewController ()

@end

@implementation BasicDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _resultsController = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
        self.view = _resultsController.view;
    }
    return self;
}

-(void)displayResults:(id <DBResultSet>)results
{
    [_resultsController displayResults:results];
}

@end
