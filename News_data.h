//
//  News_data.h
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/03.
//
//

#import <Foundation/Foundation.h>

@interface News_data : NSObject

@property(strong) NSString *S3_Data;

@property(strong) NSString *Title;
@property(assign) NSInteger Publish_Day;

@property(strong) NSString *User;
@property(assign) NSInteger Post_Day;

-(id)initWithNews:(NSString *)s3_Data
          andUser:(NSString *)theUser
         andtitle:(NSString *)title
       andpostDay:(NSInteger)postDay
    andpublishDay:(NSInteger)publishDay;

@end
