//
//  QueryViewController.h
//  Crate
//
//  Created by Alex Barlow on 28/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResultsViewController.h"
#import <MGSFragaria/MGSFragaria.h>

@interface QueryViewController : NSViewController <MGSFragariaTextViewDelegate, NSTextViewDelegate>

@property (nonatomic, strong) id <DBConnection> dbConnection;
@property (strong, nonatomic) ResultsViewController *resultsController;
@property (unsafe_unretained) IBOutlet NSTextView *queryTextView;
@property (weak) IBOutlet NSView *queryView;
@property (weak) IBOutlet NSButton *queryButton;
@property (weak) IBOutlet NSScrollView *resultTable;

@end
