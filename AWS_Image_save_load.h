//
//  AWS_Image_save_load.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/27.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "S3_SimpleDB_save_load.h"
#import "UIImage+Text.h"

@interface AWS_Image_save_load : S3_SimpleDB_save_load
{
   
}
@property (nonatomic,retain) S3_SimpleDB_save_load *S3sdb;

-(void)getImageText:(NSString *)title block:(dispatch_block_t)block;
-(void)getImageArray_with_title:(NSString *)title add_block:(dispatch_block_t)block;
-(void)getImageArray_with_category:(NSString *)category add_block:(dispatch_block_t)block;
-(void)setImageText:(UIImage_Text *)imagetext;
-(void)getImageArray:(dispatch_block_t)block;
-(NSArray *)rand_sort:(NSArray *)array;
-(UIImage_Text *)unarchived_NSData:(NSData *)data;

@end
