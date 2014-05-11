//
//  NSManagedObject+Dictionary.m
//  Crate
//
//  Created by Alex Barlow on 11/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import "NSManagedObject+Dictionary.h"

@implementation NSManagedObject (Dictionary)

-(NSDictionary*)asDictionary
{
    NSArray *keys = [[[self entity] attributesByName] allKeys];
    return [self dictionaryWithValuesForKeys:keys];
}

@end
