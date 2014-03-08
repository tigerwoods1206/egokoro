//
//  AWS_Image_save_load.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/27.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "AWS_Image_save_load.h"

@implementation AWS_Image_save_load

-(id)init
{
    self = [super init];
    if (self != nil) {
        [self init_s3sdb];
    }
    return self;
}

-(void)getImageText:(NSString *)title block:(dispatch_block_t)block
{
    [self init_s3sdb];
    [self.S3sdb Load_Data:title block:block];
}

-(void)getImageArray:(dispatch_block_t)block
{
     [self init_s3sdb];
    [self.S3sdb Load_Data_Arr:block];
}

-(void)setImageText:(UIImage_Text *)imagetext and_key:(NSString *)title
{
    [self init_s3sdb];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [self.S3sdb Save_Data:data];
}

-(UIImage_Text *)unarchived_NSData:(NSData *)data
{
    UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return imgtxt;
}

-(void)init_s3sdb
{
    if (self.S3sdb==nil) {
        self.S3sdb = [[S3_SimpleDB_save_load alloc] init];
    }
    
}

@end
