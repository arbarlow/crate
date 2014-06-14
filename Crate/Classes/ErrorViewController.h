//
//  ErrorView.h
//  Crate
//
//  Created by Alex Barlow on 09/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ErrorViewController : NSViewController

+(void)displayForWindow:(NSWindow*)window withError:(NSString*)error;

@end
