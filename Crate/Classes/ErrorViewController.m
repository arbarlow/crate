//
//  ErrorView.m
//  Crate
//
//  Created by Alex Barlow on 09/06/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "ErrorViewController.h"
#import "ColouredView.h"

@interface ErrorViewController ()

@end

@implementation ErrorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [(ColouredView*)self.view setBgColour:NSColorFromRGB(1,1,1,0.4)];
        
//        self.view.layer.masksToBounds = YES;
//        [self.view setLayer:[CALayer layer]];
//        self.view.layer.cornerRadius = 5.0;
//        [self.view setWantsLayer:YES];
    }
    return self;
}

+(void)displayForWindow:(NSWindow*)window withError:(NSString*)error{
    
}

@end
