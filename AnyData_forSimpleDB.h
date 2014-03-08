//
//  AnyData_forSimpleDB.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/15.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Codable.h"
#import <AWSSimpleDB/AWSSimpleDB.h>

#define S3DATA_ATTRIBUTE     @"s3Data"

@interface AnyData_forSimpleDB : Codable
{
    NSArray *pairdata_Array;
    NSData *self_archived_Data;
}

@property NSString *s3Data;
@property NSString *User;
@property NSString *Pubday;

//@property NSDate *nowday;

//-(id)initWithData:(NSData *)archived_Data andMainKey:(NSString *)key;
-(id)initWithKeys:(NSString *)key andUser:(NSString *)user andPubday:(NSString *)pubday;
-(id)initWithSimpleDBItem:(SimpleDBItem *)Item andPropNames:(NSArray *)props andMainKey:(NSString *)key;
-(id)initWithAttributes:(NSArray *)Attributes andPropNames:(NSArray *)props andMainKey:(NSString *)key;
-(NSString *)get_value:(NSString *)key;
-(NSMutableArray *)get_Attribute_Array;

@end
