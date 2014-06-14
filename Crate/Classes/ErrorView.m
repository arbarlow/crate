//
//  ErrorView.m
//  Crate
//
//  Created by Alex Barlow on 09/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "ErrorView.h"

@implementation ErrorView

+(id)displayForView:(NSView*)view title:(NSString*)title message:(NSString*)message
{
    ErrorView *errorView = [[self alloc] initWithNibName:@"ErrorView" bundle:nil];
    [view addSubview:errorView.view positioned:NSWindowAbove relativeTo:nil];
    
    [errorView.header setStringValue:title];
    [errorView.subHeader setStringValue:message];
    
    NSRect textSize = [message boundingRectWithSize:CGSizeMake(600, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: errorView.subHeader.font}];
 
    CGRect currentFrame = errorView.view.frame;
    currentFrame.size.width = textSize.size.width + 42;
    currentFrame.size.height = textSize.size.height + 76;
    errorView.view.frame = currentFrame;
    
    CGRect textFrame = errorView.subHeader.frame;
    textFrame.size = textSize.size;
    textFrame.size.width = textFrame.size.width + 12;
    textFrame.origin.y = textSize.size.height - 4;
    errorView.subHeader.frame = textFrame;
    
    [errorView.view setFrameOrigin:NSMakePoint(
                                               (NSWidth([view bounds]) - NSWidth([errorView.view frame])) / 2,
                                               (NSHeight([view bounds]) - NSHeight([errorView.view frame])) / 2
                                               )];
    
    [errorView.view setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [errorView.view removeFromSuperview];
        }];
        [[NSAnimationContext currentContext] setDuration:0.5];
        errorView.view.animator.alphaValue = 0;
        [NSAnimationContext endGrouping];
    });

    return errorView;
}

//- (id)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        NSImageView *errorCross = [[NSImageView alloc] initWithFrame:CGRectMake(16, frame.size.height - 46, 32, 32)];
//        errorCross.image = [NSImage imageNamed:@"cross"];
//        [self addSubview:errorCross];
//        
//        NSTextField *title = [[NSTextField alloc] initWithFrame:CGRectMake(36, frame.size.height - 46, frame.size.width - 36, 32)];
//        [title setStringValue:@"Error"];
//        title.backgroundColor = [NSColor clearColor];
//        
//        [self addSubview:title];
//        
//    }
//    return self;
//}

@end
