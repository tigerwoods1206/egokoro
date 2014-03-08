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

-(void)Save_Data:(NSData *)data;
-(void)Load_Data:(NSString *)key block:(dispatch_block_t)block;
-(void)Load_Data_Arr:(dispatch_block_t)block;
-(void)Clear_All_Data;

@end
