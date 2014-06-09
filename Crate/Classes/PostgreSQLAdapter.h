//
//  PostgreSQLAdapter.h
//  Crate
//
//  Created by Alex Barlow on 11/05/2014.
//  Copyright (c) 2014 Alex Barlow. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libpq-fe.h"

@interface PostgreSQLAdapter   : NSObject <DBConnection> @end

@interface PostgreSQLTable     : NSObject <DBTable>
-(id)initWithName:(NSString*)tableName;
@end

@interface PostgreSQLResultSet : NSObject <DBResultSet>
-(id)initWithResult:(PGresult*)result;
@end