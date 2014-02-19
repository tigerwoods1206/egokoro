//
//  S3_init.h
//  S3_SimpleData
//
//  Created by オオタ イサオ on 2014/02/10.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import <AWSRuntime/AWSRuntime.h>

@interface S3_init : NSObject
{
    
}

//@property (nonatomic, strong) AmazonS3Client *s3;

+(AmazonS3Client *)init_S3;

@end
