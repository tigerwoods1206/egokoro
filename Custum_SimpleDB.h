//
//  Custum_SimpleDB.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/30.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Codable.h"
#import "SimpleDB_DataList.h"

@interface Custum_SimpleDB : Codable <AmazonServiceRequestDelegate>

@property (nonatomic, retain) SimpleDB_DataList *sdb;
@property (nonatomic, retain) NSString *domain;


-(void)Clear_All_Data;
-(void)delete_Data:(AnyData_forSimpleDB *)deldb;
-(void)Save_props:(Save_Props *)prop andkey:(NSString *)key;
-(NSArray *)Load_Data_Arr_add_query:(NSString *)query;

@end
