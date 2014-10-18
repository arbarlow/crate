//
//  QueryViewController.h
//  Crate
//
//  Created by Alex Barlow on 28/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResultsViewController.h"

@interface QueryViewController : NSViewController

@property (weak) IBOutlet NSTextField *queryField;
@property (strong, nonatomic) ResultsViewController *resultsController;

@end
