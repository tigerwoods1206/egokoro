//
//  Const.h
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/03.
//
//

#import <Foundation/Foundation.h>

// Constants used to represent your AWS Credentials.
#define ACCESS_KEY_ID          @"AKIAJ6ZGVNZTFMZVTOFQ"
#define SECRET_KEY             @"ffIvyaxqXpg2OxQC2Gmmq1OM4YlAQImJr84vF50r"
#define CREDENTIALS_MESSAGE    @"AWS Credentials not configured correctly.  Please review the README file."

#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."

#define PICTURE_BUCKET         @"imagetext-bucket"

#define S3DATA_ATTRIBUTE     @"s3Data"
#define HIGH_SCORE_DOMAIN    @"Datas"

@interface Const:NSObject {
}

+(UIAlertView *)credentialsAlert;
/**
 * Utility method to create a bucket name using the Access Key Id.  This will help ensure uniqueness.
 */
+(NSString *)pictureBucket;

+(NSString *)nowKeystring;
+(NSString *)makeUniqueString;

@end