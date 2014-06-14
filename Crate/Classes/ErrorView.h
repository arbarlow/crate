//
//  ErrorView.h
//  Crate
//
//  Created by Alex Barlow on 09/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ErrorView : NSViewController

@property (weak) IBOutlet NSTextField *header;
@property (weak) IBOutlet NSTextField *subHeader;

+(id)displayForView:(NSView*)view title:(NSString*)title message:(NSString*)message;

@end
