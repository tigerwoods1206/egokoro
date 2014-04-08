//
//  IINE_method.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/30.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "IINE_method.h"

@implementation IINE_method

-(id)init
{
    self = [super init];
    if (self != nil) {
        [self init_csdb];
    }
    return self;
}

-(BOOL)Vote_IINE:(AnyData_forSimpleDB *)adb
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyMMddHHmm"];
    
    NSDate *today = [NSDate date];
    NSString *strNow = [inputFormatter stringFromDate:today];
    strNow = [strNow stringByReplacingOccurrencesOfString:@" " withString:@""];
   
    NSString *news_title = [adb get_value:@"news_title"];
    NSString *user       = [adb get_value:@"user"];
    NSString *category   = [adb get_value:@"category"];
    NSString *key        = [adb get_value:@"s3Data"];
    NSArray *iinearr = [Csdb Load_Data_Arr_add_query:[self create_title_user_query:news_title and_user:user]];
    if([iinearr count] == 0){
        Save_Props *props = [[Save_Props alloc] init];
        props.user   = user;
        props.Pubday = strNow;
        props.news_title = news_title;
        props.category = category;
        props.hpadress = @"1";
        [Csdb Save_props:props andkey:key];
        return YES;
    }
    
    AnyData_forSimpleDB *csbdata = [iinearr objectAtIndex:0];
    //csbdata.s3Data = Csdb.sdb.mainKey;
    if ([self is_enable_vote_iine]) {
        NSString *votenum_str = [csbdata get_value:@"hpadress"];
        int votenum = [votenum_str intValue];
        votenum++;
        NSString *incr_votenum_str = [NSString stringWithFormat:@"%d",votenum];
        
        [Csdb delete_Data:csbdata];
    //[Csdb Clear_All_Data];
        Save_Props *props = [[Save_Props alloc] init];
        props.user   = user;
        props.Pubday = strNow;
        props.news_title = news_title;
        props.category = category;
        props.hpadress = incr_votenum_str;
        [Csdb Save_props:props andkey:key];
        return YES;
    }
    
    return NO;
}

-(NSArray *)Get_IINE:(NSString *)USERID and_news_title:(NSString *)news_title
{
   // NSMutableArray *marr = [[NSMutableArray alloc] init];
    
    NSArray *iinearr = [Csdb Load_Data_Arr_add_query:[self create_title_user_query:news_title and_user:USERID]];
    
    return iinearr;
}


-(BOOL)is_enable_vote_iine
{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    /*
    NSInteger votenum = [ud integerForKey:@"VOTE_NUM"];
    if (votenum == 0) {
        votenum++;
        [ud setInteger:votenum forKey:@"VOTE_NUM"];
        return YES;
    }
    */
    NSDate *dataDay = [ud objectForKey:@"VOTE_DAY"];
    if (dataDay==nil) {
        dataDay = [NSDate date];
        [ud setObject:dataDay forKey:@"VOTE_DAY"];
    }
    NSDate *oneDayafter = [dataDay initWithTimeInterval:24*60*60 sinceDate:dataDay];
    
    NSDate *today = [NSDate date];
    if ([today compare:oneDayafter] == NSOrderedDescending) {
       // NSData *data = [NSKeyedArchiver archivedDataWithRootObject:today];
        [ud setObject:today forKey:@"VOTE_DAY"];
        return YES;
    }
    return NO;
}

-(void)delete_Vote_All
{
    [self init_csdb];
    [Csdb.sdb clearData];
}

-(void)init_csdb
{
    Csdb = [[Custum_SimpleDB alloc] init];
}

-(NSString *)create_title_query:(NSString *)title
{
    NSString *query;
    query = [NSString stringWithFormat:@"select * from %@ where news_title = '%@' limit %d",
             Csdb.domain,title,DATALIMIT];
    return query;
}


-(NSString *)create_title_user_query:(NSString *)title and_user:(NSString *)user
{
    NSString *query;
    query = [NSString stringWithFormat:@"select * from %@ where news_title = '%@' and user = '%@' limit %d",
             Csdb.domain,title,user,DATALIMIT];
    return query;
}

@end
