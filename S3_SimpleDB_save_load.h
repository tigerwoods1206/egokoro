//
//  S3_SimpleDB_save_load.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/24.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "S3_init.h"
#import "Codable.h"
#import "SimpleDB_DataList.h"

@interface S3_SimpleDB_save_load : Codable <AmazonServiceRequestDelegate>

@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) SimpleDB_DataList *sdb;
@property (nonatomic, retain) NSArray *Data_Arr;
@property (nonatomic, retain) NSArray *Adb_Arr;

-(void)Save_Data:(NSData *)data and_props:(Save_Props *)prop;
-(void)Load_Data:(NSString *)key block:(dispatch_block_t)block;
-(void)Load_Data_Arr:(NSArray *)adbarr and_block:(dispatch_block_t)block;
-(void)Load_Data_Arr:(dispatch_block_t)block;
-(void)Load_Data_Arr:(dispatch_block_t)block add_query:(NSString *)query;
-(void)Clear_All_Data;
-(void)Delete_Data_for_query:(NSString *)query;

@end
