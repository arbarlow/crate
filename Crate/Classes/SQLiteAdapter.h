//
//  SQLiteAdapter.h
//  Crate
//
//  Created by Alex Barlow on 22/01/2015.
//  Copyright (c) 2015 Alex Barlow. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

@interface SQLiteAdapter : NSObject  <DBConnection> @end

@interface SQLiteTable : NSObject  <DBTable>
-(id)initWithName:(NSString*)tableName;
@end

@interface SQLiteResultSet : NSObject  <DBResultSet>
-(id)initWithResult:(PGresult*)result;
@end