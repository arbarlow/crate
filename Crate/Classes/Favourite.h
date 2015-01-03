//
//  Favourite.h
//  Crate
//
//  Created by Alex Barlow on 02/01/2015.
//  Copyright (c) 2015 Alex Barlow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favourite : NSManagedObject

@property (nonatomic, retain) NSString * database_name;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSDate * timestamp;

@end
