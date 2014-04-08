//
//  IINE_method.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/30.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Custum_SimpleDB.h"

@interface IINE_method : NSObject
{
    Custum_SimpleDB *Csdb;
}

-(BOOL)Vote_IINE:(AnyData_forSimpleDB *)adb;
-(NSArray *)Get_IINE:(NSString *)USERID and_news_title:(NSString *)news_title;
-(void)delete_Vote_All;

@end
