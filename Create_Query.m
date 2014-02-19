//
//  Create_Query.m
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/10.
//
//

#import "Create_Query.h"

@implementation Create_Query

+(NSString *)create_query:(NSDate *)lastday
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyMMddHHmm"];
    NSString *strNow = [df stringFromDate:lastday];
    
    NSString *query = [NSString stringWithFormat:@"select s3data, user, title, publish_day,post_day from News where publish_day > '%@' order by publish_day asc",strNow];
    return query;
}

+(NSString *)create_query:(NSArray *)properties  and_main_key:(NSString *)main_key  and_day_key:(NSString *)day_key and_last_day:(NSDate *)lastday;
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyMMddHHmm"];
    NSString *strNow = [df stringFromDate:lastday];
    
    //NSArray *props = [data propertyNames];
    NSString *query = [NSString stringWithFormat:@"select "];
    for (NSString *prop in properties) {
        if ([prop compare:main_key]) {
            [query stringByAppendingFormat:@"%@, ", main_key ];
        }
    }
    
    for (NSString *prop in properties) {
        if (![prop compare:main_key]) {
            [query stringByAppendingFormat:@"%@, ", prop];
        }
    }
    
    [query stringByAppendingFormat:@"from News where %@ > '%@' order by %@ asc",day_key,strNow,day_key];
    
    return query;
}

@end
