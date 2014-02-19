//
//  News_data.m
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/03.
//
//

#import "News_data.h"

@implementation News_data

@synthesize S3_Data;
@synthesize User;
@synthesize Title;
@synthesize Post_Day;
@synthesize Publish_Day;


-(id)initWithNews:(NSString *)s3_Data
          andUser:(NSString *)theUser
         andtitle:(NSString *)title
       andpostDay:(NSInteger)postDay
    andpublishDay:(NSInteger)publishDay
{
    self = [super init];
    if (self)
    {
        S3_Data   = s3_Data;
        User      = theUser;
        Title     = title;
        Post_Day  = postDay;
        Publish_Day = publishDay;
    }
    
    return self;
}



@end
