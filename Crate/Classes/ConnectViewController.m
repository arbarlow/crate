//
//  ConnectViewController.m
//  Crate
//
//  Created by Alex Barlow on 06/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//


#import "ConnectViewController.h"
#import "CrateWindowController.h"
#import "ColouredView.h"

@interface ConnectViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *favs;
@property (weak) IBOutlet NSTextFieldCell *errorField;

@end

@implementation ConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [(ColouredView*)self.view setBgColour:NSColorFromRGB(51, 56, 60, 1)];
        [_tableView setFocusRingType:NSFocusRingTypeNone];
        [_tableView setTarget:self];
        [_tableView setDoubleAction:@selector(didClickRow:)];
    }
    return self;
}
         
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[self favourites] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    Favourite *fav = [[self favourites] objectAtIndex:row];
    NSString *identifier = tableColumn.identifier;
    
    NSView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];

    if ([identifier isEqualToString:@"0"]){
        [[[view subviews] lastObject] setStringValue:fav.name];
        return view;
    }else{
        return nil;
    }
}

-(void)didClickRow:(id)sender
{
    if ([sender clickedRow] != -1) {
        Favourite *fav = [[self favourites] objectAtIndex:[sender clickedRow]];
        [_delegate connectWithDictionary:[fav asDictionary]];
    }
}
         
-(NSArray*)favourites
{
    if (!_favs) {
        _favs = [Favourite MR_findAll];
    }
    
    return _favs;
}

@end
