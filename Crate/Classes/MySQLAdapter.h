//
//  MySQLAdapter.h
//  Crate
//
//  Created by Alex Barlow on 03/01/2015.
//  Copyright (c) 2015 Alex Barlow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mysql/mysql.h"

@interface MySQLAdapter   : NSObject <DBConnection> @end

@interface MySQLTable     : NSObject <DBTable>
-(id)initWithName:(NSString*)tableName;
@end

@interface MySQLResultSet : NSObject <DBResultSet>
-(id)initWithResult:(MYSQL_RES*)result;
@end