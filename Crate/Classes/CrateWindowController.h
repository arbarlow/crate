//
//  CrateWindowController.h
//  Crate
//
//  Created by Alex Barlow on 06/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConnectViewController.h"
#import "ConnectionViewController.h"


@interface CrateWindowController : NSWindowController <NSWindowDelegate>

@property (weak) IBOutlet NSView *titleView;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSPopUpButtonCell *databaseSelectButton;
@property (weak) IBOutlet NSSegmentedControl *viewSelector;

-(void)connectWithDictionary:(NSDictionary*)dict;

@end