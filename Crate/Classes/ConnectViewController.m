//
//  ConnectViewController.m
//  Crate
//
//  Created by Alex Barlow on 06/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//


#import "ConnectViewController.h"
#import "CrateWindowController.h"

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
@property (weak) IBOutlet NSPopUpButton *adapterField;

@property (weak) IBOutlet NSButton *connectButton;


@end

@implementation ConnectViewController

-(void)loadView{
    [super loadView];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] byExtendingSelection:NO];
}

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
    fav.name ? [_nameField setStringValue:fav.name] : [self setCellToBlank:_nameField];
    fav.host ? [_hostField setStringValue:fav.host] : [self setCellToBlank:_hostField];
    fav.port ? [_portField setStringValue:fav.port] : [self setCellToBlank:_portField];
    fav.user ? [_userField setStringValue:fav.user] : [self setCellToBlank:_userField];
    fav.database_name ? [_dbField setStringValue:fav.database_name] : [self setCellToBlank:_dbField];
    fav.password ? [_passwordField setStringValue:fav.password] : [self setCellToBlank:_passwordField];
    [_adapterField selectItemWithTitle:fav.adapter];
    
    [_connectButton setTitle:@"Connect"];
}

-(void)setCellToBlank:(NSTextField*)field{
    [field setStringValue:@""];
    [[field cell] setPlaceholderString:@"NULL"];
}

- (IBAction)didClickConnect:(id)sender {
    Favourite *fav = _favs[[_tableView selectedRow]];
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo disableSuddenTermination];
    [processInfo disableAutomaticTermination:@"Application is currently saving to persistent store"];
    
    fav.name = [[_nameField stringValue] isEqualToString:@""] ? nil : [_nameField stringValue];
    fav.host = [[_hostField stringValue] isEqualToString:@""] ? nil : [_hostField stringValue];
    fav.port = [[_portField stringValue] isEqualToString:@""] ? nil : [_portField stringValue];
    fav.user = [[_userField stringValue] isEqualToString:@""] ? nil : [_userField stringValue];
    fav.database_name = [[_dbField stringValue] isEqualToString:@""] ? nil : [_dbField stringValue];
    fav.password = [[_passwordField stringValue] isEqualToString:@""] ? nil : [_passwordField stringValue];
    fav.adapter = [_adapterField titleOfSelectedItem];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [processInfo enableSuddenTermination];
        [processInfo enableAutomaticTermination:@"Application has finished saving to the persistent store"];
        
        [_delegate connectWithDictionary:[fav asDictionary]];
    }];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [_connectButton setTitle:@"Save & Connect"];
}

- (IBAction)didClickAdd:(id)sender {
    Favourite *fav = [Favourite MR_createEntity];
    fav.name = @"Untitled";
    fav.host = @"localhost";
    fav.user = @"root";
    fav.adapter = @"MySQL";
    fav.timestamp = [NSDate date];
    _favs = [Favourite MR_findAllSortedBy:@"timestamp" ascending:YES];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^(BOOL success, NSError *error) {
        [_tableView reloadData];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[_favs count]-1];
        [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }];
}

- (IBAction)didClickRemove:(id)sender {
    Favourite *fav = _favs[[_tableView selectedRow]];
    [fav MR_deleteEntity];
    _favs = [Favourite MR_findAllSortedBy:@"timestamp" ascending:YES];
    
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
    } completion:^(BOOL success, NSError *error) {
        [_tableView reloadData];
    }];
}

         
-(NSArray*)favourites
{
    if (!_favs) {
        _favs = [Favourite MR_findAllSortedBy:@"timestamp" ascending:YES];
    }
    
    return _favs;
}

@end
