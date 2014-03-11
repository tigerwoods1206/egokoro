//
//  Create_Query.h
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/10.
//
//

#import <Foundation/Foundation.h>
#import "Codable.h"
#import "Const.h"

@interface Create_Query : NSObject

+(NSString *)create_query:(NSDate *)lastday;
+(NSString *)create_query:(NSArray *)properties  and_main_key:(NSString *)main_key  and_day_key:(NSString *)day_key and_last_day:(NSDate *)lastday;
+(NSString *)create_title_query:(NSString *)title;

@end
