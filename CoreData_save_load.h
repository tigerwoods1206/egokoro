//
//  CoreData_save_load.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/13.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreData_save_load : NSObject
{
    NSManagedObjectContext *context;
    NSPersistentStoreCoordinator *coordinator;
    NSManagedObjectModel *managedObjectModel;
}


-(void)store_NSData:(NSData *)data anddate:(NSDate *)date;
-(void)store_NSData:(NSData *)data andkey:(NSString *)key;
-(NSData *)get_Data:(NSDate *)date;
-(NSData *)get_Data_from_key:(NSString *)key;

-(NSArray *)get_dataarray:(int)before_day;
-(void)del_allData;
-(id)init;
@end
