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
    
    [self.view addSubview:_resultsController.view];
    [_resultsController.view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_queryView];
    [_resultsController.view autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
    [_resultsController.view autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
    [_resultsController.view autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
    
    MGSFragaria *fragaria = [[MGSFragaria alloc] init];
    [fragaria setObject:self forKey:MGSFODelegate];

    [fragaria setObject:@"sql" forKey:MGSFOSyntaxDefinitionName];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
        [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
    
    [fragaria embedInView:_queryView];
    [fragaria setString:@"-- SELECT * FROM users;"];
    _queryTextView = fragaria.textView;
    
    [_queryButton removeFromSuperview];
    [_queryView addSubview:_queryButton];
    
    [_queryButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_queryView withOffset:-14.f];
    [_queryButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_queryView withOffset:-20.f];
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(NSString *)aSelector {
    NSUInteger flags = ([NSApp currentEvent].modifierFlags & NSDeviceIndependentModifierFlagsMask);
    BOOL isCommand = (flags & NSCommandKeyMask) == NSCommandKeyMask;
    BOOL isEnter = ([NSApp currentEvent].keyCode == 0x24); // VK_RETURN
    if (isCommand && isEnter) {
        [self didRunQuery:_queryButton];
        return YES;
    } else {
       return NO;
    }
}


- (IBAction)didRunQuery:(id)sender {
    [_dbConnection execQuery:[[_queryTextView textStorage] string] success:^(id<DBResultSet> resultSet, NSTimeInterval elapsedTime) {
        [_resultsController displayResults:resultSet];
    } failure:^(NSString *error) {
        [ErrorView displayForView:[_resultsController.view.subviews lastObject]
                            title:@"Query Error"
                          message:error];
    }];
}

@end
