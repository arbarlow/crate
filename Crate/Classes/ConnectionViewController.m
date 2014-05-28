//
//  ConnectionViewController.m
//  Crate
//
//  Created by Alex Barlow on 10/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "ConnectionViewController.h"


@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tables = [NSMutableArray array];
        
        _schemaView = [[SchemaViewController alloc] initWithNibName:@"SchemaViewController" bundle:nil];
        _basicDataView = [[BasicDataViewController alloc] initWithNibName:@"BasicDataViewController" bundle:nil];
        _queryView = [[QueryViewController alloc] initWithNibName:@"QueryViewController" bundle:nil];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    // Set schema as first view
    _schemaView.view.frame = [[self.view.subviews lastObject] frame];
    [self.view replaceSubview:[self.view.subviews lastObject] with:_schemaView.view];
}

-(void)didSwitchView:(NSInteger)viewSelected
{
    switch (viewSelected) {
        case 0:
            [self switchToView:_schemaView.view];
            break;
        case 1:
            [self switchToView:_basicDataView.view];
            break;
        case 2:
            [self switchToView:_queryView.view];
            break;
        default:
            break;
    }
}

-(void)switchToView:(NSView*)switchView
{
    switchView.frame = [[self.view.subviews lastObject] frame];
    [self.view replaceSubview:[self.view.subviews lastObject] with:switchView];
}

-(void)displayTables
{
    [_dbConnection tablesForDatabaseWithSuccess:^(NSArray *tables) {
        NSMutableArray *mutableTables = [self mutableArrayValueForKey:@"tables"];
        [mutableTables removeAllObjects];
        [mutableTables addObjectsFromArray:tables];
    } failure:^(NSString *error) {
        NSLog(@"error");
    }];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSLog(@"hello %@", aNotification.object);
}
@end
