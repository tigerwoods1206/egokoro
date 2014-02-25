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

@interface S3_SimpleDB_save_load : Codable

@property (nonatomic, retain) AmazonS3Client *s3;

-(void)Save_Data:(NSData *)data;
-(NSData *)Load_Data:(NSString *)key;

@end
