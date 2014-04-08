//
//  Const.m
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/03.
//
//

#import "Const.h"

@implementation Const

+(UIAlertView *)credentialsAlert
{
    return [[UIAlertView alloc] initWithTitle:@"Missing Credentials" message:CREDENTIALS_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

+(NSString *)pictureBucket
{
    return [[NSString stringWithFormat:@"%@-%@", PICTURE_BUCKET, ACCESS_KEY_ID] lowercaseString];
}

+(NSString *)nowKeystring
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
    [df setDateFormat:@"yyMMddHHmm"];
    
    NSDate *now = [NSDate date];
    NSString *strNow = [df stringFromDate:now];
    strNow = [strNow stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return strNow;
}

+(NSString *)makeUniqueString
	{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyMMddHHmmss"];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        
        srandom((unsigned) time(NULL));
        int randomValue = arc4random() % 1000;
        NSString *unique = [NSString stringWithFormat:@"%@.%d",dateString,randomValue];
   	    
   	    return unique;
    }

@end
