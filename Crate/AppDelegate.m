//
//  AppDelegate.m
//  Crate
//
//  Created by Alex Barlow on 06/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "AppDelegate.h"
#import "CrateWindowController.h"

@implementation AppDelegate

static NSString *storeName = @"Crate.sqlite";

-(id)init
{
	if ((self = [super init])) {
        _windows = [NSMutableArray array];
		[NSApp setDelegate:self];
	}
    
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:storeName];
    [self createDefaultFavourite];
    
    if ([_windows count] == 0) {
        [self createNewWindow];
    }
}

- (IBAction)newWindowFromMenu:(id)sender {
    [self createNewWindow];
}

-(void)createNewWindow
{
    CrateWindowController *cWc = [[CrateWindowController alloc] initWithWindowNibName:@"CrateWindowController"];
    [_windows addObject:cWc];
    
    NSWindow *newWindow = [cWc window];
    [newWindow setDelegate:cWc];
    [newWindow makeKeyWindow];
}

-(void)createDefaultFavourite
{
    int favCount = (int)[[Favourite MR_findAll] count];
    if (favCount == 0) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            Favourite *defaultFav = [Favourite MR_createInContext:localContext];
            defaultFav.name = @"Localhost";
            defaultFav.host = @"localhost";
            defaultFav.database_name = @"postgres";
            defaultFav.timestamp = [NSDate date];
        }];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    [MagicalRecord cleanUp];
    return NSTerminateNow;
}

@end
