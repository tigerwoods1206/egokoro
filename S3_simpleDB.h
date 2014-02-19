//
//  S3_simpleDB.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/14.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "S3_init.h"
#import "Codable.h"

@interface S3_simpleDB : Codable
{
    AmazonS3Client *s3;
}


-(void)uploadData:(NSData *)data;
@end
