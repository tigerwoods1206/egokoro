//
//  Imagetext_save_load.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/19.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Imagetext_save_load.h"

@implementation Imagetext_save_load

-(id)init
{
    self = [super init];
    if (self != nil) {
        inst = [[CoreData_save_load alloc] init];
    }
    return self;
}

-(UIImage_Text *)getImageText:(NSString *)title;
{
    NSData *load_data = [inst get_Data_from_key:title];
    if(load_data!=nil){
        UIImage_Text *load_image = [NSKeyedUnarchiver unarchiveObjectWithData:load_data];
        return load_image;
    }
    return nil;
}

-(NSArray *)getImage_OneTitle_Array:(NSString *)title
{
    NSArray *dataarr = [inst get_Data_Array_from_key:title];
    NSMutableArray *imgarr = [[NSMutableArray alloc] init];
    for(NSData *data in dataarr)
    {
        if(data!=nil){
            UIImage_Text *load_image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [imgarr addObject:load_image];
        }
        
    }
    return imgarr;
}

-(void)setImageText:(UIImage_Text *)imagetext and_key:(NSString *)title;
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [inst store_NSData:data andkey:title];
}

-(NSArray *)getImageArray
{
    NSArray *dataarr = [inst get_dataarray:7];
    NSMutableArray *imgarr = [[NSMutableArray alloc] init];
    for(NSData *data in dataarr)
    {
        if(data!=nil){
            UIImage_Text *load_image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [imgarr addObject:load_image];
        }

    }
    return imgarr;
}

-(void)delAllImage
{
    [inst del_allData];
}

@end
