//
//  QueryViewController.m
//  Crate
//
//  Created by Alex Barlow on 28/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "QueryViewController.h"

@interface QueryViewController ()

@end

@implementation QueryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _resultsController = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
    }
    return self;
}

-(void)loadView {
    [super loadView];
    [self.view replaceSubview:[self.view.subviews lastObject] with:_resultsController.view];
    
//    [_resultsController.view addConstraint:NSLayoutconstraint]
}

@end
