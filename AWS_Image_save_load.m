//
//  AWS_Image_save_load.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/27.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "AWS_Image_save_load.h"
#import "Custum_SimpleDB.h"

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

-(void)getImageArray_with_category:(NSString *)category add_block:(dispatch_block_t)block
{
    [self init_s3sdb];
    [self.S3sdb Load_Data_Arr:block add_query:[Create_Query create_category_query:category]];
}

-(void)getImageArray_with_title:(NSString *)title add_block:(dispatch_block_t)block
{
    [self init_s3sdb];
    [self.S3sdb Load_Data_Arr:block add_query:[Create_Query create_title_query:title]];
}

-(void)getImageArray_with_title:(NSString *)title and_user:(NSString *)user  add_block:(dispatch_block_t)block
{
    [self init_s3sdb];
    [self.S3sdb Load_Data_Arr:block add_query:[Create_Query create_title_query:title andUser:user]];
}

-(void)getImageArray_ranking:(dispatch_block_t)block
{
    Custum_SimpleDB *csdb = [[Custum_SimpleDB alloc] init];
    NSArray *adbarr = [csdb Load_Data_Arr_add_query:@"select * from `IINes`  where hpadress > '0' order by hpadress desc"];
    
    [self init_s3sdb];
    [self.S3sdb Load_Data_Arr:adbarr and_block:block];
}

-(void)setImageText:(UIImage_Text *)imagetext
{
    [self init_s3sdb];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    Save_Props *props = [[Save_Props alloc] init];
    [props set_ImageText:imagetext];
    /*
    props.news_title = imagetext.news_title;
    props.user = imagetext.user;
   // props.pubday = [Const nowKeystring];
    props.pubday = imagetext.pub_day;
     */
    [self.S3sdb Save_Data:data and_props:props];
}

-(void)delImageText:(UIImage_Text *)imgtext
{
    [self init_s3sdb];
    NSString *query = [Create_Query create_title_query:imgtext.news_title andUser:imgtext.user];
    [self.S3sdb Delete_Data_for_query:query];
}

-(NSArray *)rand_sort:(NSArray *)array
{
    
    NSMutableArray *sort_arr = [[NSMutableArray alloc] init];
    srandom((unsigned) time(NULL));
    //int rand_num = random() % [array count];
    
    NSMutableArray *iarr = [[NSMutableArray alloc] init];
    for (int i=0; i < [array count]; i++) {
        [iarr addObject:[NSNumber numberWithInt:i]];
    }
    
    int rand_num;
    for (int i=0; i < [array count]; i++) {
        rand_num = random() % [iarr count];
        
        id randid = [iarr objectAtIndex:rand_num];
        int idx = [(NSNumber *)(randid) intValue];
        [sort_arr addObject:[array objectAtIndex:idx]];
        [iarr removeObject:randid];
    }
    return sort_arr;
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
