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

-(void)connectWithDictionary:(NSDictionary*)dict;

@end