//
//  CreateUserID.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/30.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "CreateUserID.h"

@implementation CreateUserID


+(NSInteger)CreateUserID
{
    NSInteger ret_userID = -1;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    ret_userID = [ud integerForKey:@"USER_ID"];
    if(ret_userID != -1)
    {
        return ret_userID;
    }
    else {
        ret_userID = random();
       
        [ud setInteger:ret_userID forKey:@"USER_ID"];  // int型の100をKEY_Iというキーで保存
        
        return ret_userID;
    }
}

@end
