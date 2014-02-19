//
//  SimpleDB_DataList.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/15.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Codable.h"
#import "AnyData_forSimpleDB.h"

#define NO_SORT        0
#define PLAYER_SORT    1
#define SCORE_SORT     2

@interface SimpleDB_DataList : Codable
{
    AmazonSimpleDBClient *sdbClient;
    NSString             *nextToken;
    NSData               *_archived_Data;
    NSString             *mainKey;
    int                  sortMethod;
}


@property (nonatomic, strong) NSString *nextToken;

-(id)initWithSortMethod:(int)theSortMethod;
-(id)initWithProperties:(NSData *)archived_Data andMainkey:(NSString *)key;
-(int)DataCount;
-(NSArray *)getDatas;
-(NSArray *)getNextPageOfData;
-(void)addData:(AnyData_forSimpleDB *)theData;
-(void)removeData:(AnyData_forSimpleDB *)theData;
-(void)createDataDomain;
-(void)clearData;
-(AnyData_forSimpleDB *)getS3Data:(NSString *)one_key;


// Utility Methods
-(NSArray *)getClassProperties:(NSData *)archived_Data;
-(NSArray *)convertItemsToData:(NSArray *)theItems;
-(AnyData_forSimpleDB *)convertSimpleDBItemToData:(SimpleDBItem *)theItem;

-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getPaddedDay:(int)theDay;

@end
