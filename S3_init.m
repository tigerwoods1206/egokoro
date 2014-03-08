//
//  S3_init.m
//  S3_SimpleData
//
//  Created by オオタ イサオ on 2014/02/10.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "S3_init.h"
#import "Const.h"


@implementation S3_init

+(AmazonS3Client *)init_S3
{
    @try {
        AmazonS3Client *s3;
        s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        s3.endpoint = [AmazonEndpoints s3Endpoint:AP_NORTHEAST_1];
        
        // Create the picture bucket.
        /*
        S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[Const pictureBucket] andRegion:[S3Region APJapan]];
        S3CreateBucketResponse *createBucketResponse = [s3 createBucket:createBucketRequest];
        if(createBucketResponse.error != nil)
        {
            NSLog(@"Error: %@", createBucketResponse.error);
            // return nil;
        }
         */
        return s3;
    }
    @catch (AmazonServiceException* asex) {
        NSLog(@"putObject - AmazonServiceException - %@", asex);
    }
    
    @catch (AmazonClientException* acex) {
        NSLog(@"putObject - AmazonClientException - %@", acex);
    }

}

@end
