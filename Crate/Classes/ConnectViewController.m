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

// Form fields
@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *hostField;
@property (weak) IBOutlet NSTextField *portField;
@property (weak) IBOutlet NSTextField *userField;
@property (weak) IBOutlet NSTextField *dbField;
@property (weak) IBOutlet NSSecureTextField *passwordField;

@property (weak) IBOutlet NSButton *connectButton;

@end

@implementation ConnectViewController

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[self favourites] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
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

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    Favourite *fav = _favs[[(NSTableView*)aNotification.object selectedRow]];
    fav.name ? [_nameField setStringValue:fav.name] : [[_nameField cell] setPlaceholderString:@"NULL"];
    fav.host ? [_hostField setStringValue:fav.host] : [[_hostField cell] setPlaceholderString:@"NULL"];
    fav.port ? [_portField setStringValue:fav.port] : [[_portField cell] setPlaceholderString:@"NULL"];
    fav.user ? [_userField setStringValue:fav.user] : [[_userField cell] setPlaceholderString:@"NULL"];
    fav.database_name ? [_dbField setStringValue:fav.database_name] : [[_dbField cell] setPlaceholderString:@"NULL"];
    fav.password ? [_passwordField setStringValue:fav.password] : [[_passwordField cell] setPlaceholderString:@"NULL"];;
    
    [_connectButton setTitle:@"Connect"];
}

- (IBAction)didClickConnect:(id)sender {
    Favourite *fav = _favs[[_tableView selectedRow]];
    [_delegate connectWithDictionary:[fav asDictionary]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [_connectButton setTitle:@"Save & Connect"];
}
         
-(NSArray*)favourites
{
    if (!_favs) {
        _favs = [Favourite MR_findAll];
    }
    
    return _favs;
}

@end
