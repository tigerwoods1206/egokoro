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

-(void)setImageText:(UIImage_Text *)imagetext and_key:(NSString *)title;
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [inst store_NSData:data andkey:title];
}

@end