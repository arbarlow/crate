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
    }
    return self;
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
