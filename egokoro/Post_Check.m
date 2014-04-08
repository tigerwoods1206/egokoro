//
//  Post_Check.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/04/05.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Post_Check.h"

@implementation Post_Check

+(BOOL)chk_enable_post
{
    NSInteger Max_Post_Num = 10;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    
    NSInteger postnum = [ud integerForKey:@"POST_NUM"];
    
    if (postnum==0) {
        postnum++;
        [ud setInteger:postnum forKey:@"POST_NUM"];
        return YES;
    }
    
    postnum++;
    [ud setInteger:postnum forKey:@"POST_NUM"];
    
    NSDate *dataDay = [ud objectForKey:@"POST_DAY"];
    if (dataDay==nil) {
        dataDay = [NSDate date];
        [ud setObject:dataDay forKey:@"POST_DAY"];
    }
   // NSDate *oneDayafter = [dataDay initWithTimeInterval:24*60*60 sinceDate:dataDay];
    NSDate *oneDayafter = [dataDay initWithTimeInterval:24*60*60 sinceDate:dataDay];
    
    NSDate *today = [NSDate date];
    if ([today compare:oneDayafter] == NSOrderedDescending) {
        //NSData *data = [NSKeyedArchiver archivedDataWithRootObject:today];
        [ud setObject:today forKey:@"POST_DAY"];
        
        postnum = 0;
        [ud setInteger:postnum forKey:@"POST_NUM"];
        return NO;
    }
    
    if (postnum > Max_Post_Num) {
        return NO;
    }
    
    return YES;
}

@end
