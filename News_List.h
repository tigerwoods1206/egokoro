//
//  News_List.h
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/03.
//
//

#import <AWSSimpleDB/AWSSimpleDB.h>
#import "News_data.h"

#define NO_SORT        0
#define PLAYER_SORT    1
#define SCORE_SORT     2

@interface News_List : NSObject
{
    AmazonSimpleDBClient *sdbClient;
    NSString             *nextToken;
    int                  sortMethod;
}

@property (nonatomic, strong) NSString *nextToken;

-(id)initWithSortMethod:(int)theSortMethod;
-(int)newsCount;
-(NSArray *)getNewses;
-(NSArray *)getNextPageOfNews;
-(void)addNews:(News_data *)theNews;
-(void)removeNews:(News_data *)theNews;
-(void)createNewsDomain;
-(void)clearNews;
-(News_data *)getS3Data:(NSString *)s3Data;


// Utility Methods
-(NSArray *)convertItemsToNews:(NSArray *)items;
-(News_data *)convertSimpleDBItemToNews:(SimpleDBItem *)theItem;

-(NSString *)gets3dataFromItem:(SimpleDBItem *)theItem;
-(NSString *)gettitleFromItem:(SimpleDBItem *)theItem;
-(NSString *)getuserFromItem:(SimpleDBItem *)theItem;
-(int)getpublishdayFromItem:(SimpleDBItem *)theItem;
-(int)getpostdayFromItem:(SimpleDBItem *)theItem;

-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getPaddedDay:(int)theDay;


@end
