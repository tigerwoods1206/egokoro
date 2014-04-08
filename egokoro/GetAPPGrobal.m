//
//  GetAPPGrobal.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/30.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "GetAPPGrobal.h"

@implementation GetAPPGrobal

+(NSString *)get_USERID
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *IDSTR = [NSString stringWithFormat:@"%ld",app.USERID];
    return  IDSTR;
}

@end
