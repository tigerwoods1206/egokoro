//
//  News_List.m
//  HighScores
//
//  Created by オオタ イサオ on 2014/02/03.
//
//

#import "News_List.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Const.h"
#import "Create_Query.h"

#define HIGH_SCORE_DOMAIN    @"News"

#define S3DATA_ATTRIBUTE     @"s3data"
#define USER_ATTRIBUTE      @"user"
#define PUBLISHDAY_ATTRIBUTE @"publish_day"

#define POSTDAY_ATTRIBUTE    @"post_day"
#define TITLE_ATTRIBUTE      @"title"


#define COUNT_QUERY          @"select count(*) from News"

#define PUBDAY_SORT_QUERY    @"select s3data, user, title, publish_day, post_day from News where publish_day > '140130' order by publish_day asc"
#define USER_SORT_QUERY     @"select s3data, user, title, publish_day, post_day from News where user >= '' order by user desc"
#define NO_SORT_QUERY        @"select s3data, user, title, publish_day, post_day from News"

@implementation News_List

@synthesize nextToken;

-(id)init
{
    self = [super init];
    if (self)
    {
        // Initial the SimpleDB Client.
        sdbClient      = [[AmazonSimpleDBClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sdbClient.endpoint = [AmazonEndpoints sdbEndpoint:AP_NORTHEAST_1];
        
        
        self.nextToken = nil;
        sortMethod     = NO_SORT;
    }
    
    return self;
}

-(id)initWithSortMethod:(int)theSortMethod
{
    self = [super init];
    if (self)
    {
        // Initial the SimpleDB Client.
        sdbClient      = [[AmazonSimpleDBClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sdbClient.endpoint = [AmazonEndpoints sdbEndpoint:AP_NORTHEAST_1];
        
        self.nextToken = nil;
        sortMethod     = theSortMethod;
    }
    
    return self;
}

/*
 * Method returns the number of items in the High Scores Domain.
 */
-(int)newsCount
{
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc] initWithSelectExpression:COUNT_QUERY];
    selectRequest.consistentRead = YES;
    
    SimpleDBSelectResponse *selectResponse = [sdbClient select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return 0;
    }
    
    SimpleDBItem *countItem = [selectResponse.items objectAtIndex:0];
    
    return [self getIntValueForAttribute:@"Count" fromList:countItem.attributes];
}

/*
 * Gets the item from the High Scores domain with the item name equal to 'thePlayer'.
 */
-(News_data *)getS3Data:(NSString *)s3data
{
    SimpleDBGetAttributesRequest *gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:s3data];
    SimpleDBGetAttributesResponse *response = [sdbClient getAttributes:gar];
    //[gar release];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    s3data =  [self getStringValueForAttribute:S3DATA_ATTRIBUTE fromList:response.attributes];
    NSString *title  =  [self getStringValueForAttribute:TITLE_ATTRIBUTE fromList:response.attributes];
    NSString *user   =  [self getStringValueForAttribute:USER_ATTRIBUTE fromList:response.attributes];
    int postday      =  [self getIntValueForAttribute:POSTDAY_ATTRIBUTE fromList:response.attributes];
    int pubday       =  [self getIntValueForAttribute:PUBLISHDAY_ATTRIBUTE fromList:response.attributes];
    
    return [[News_data alloc] initWithNews:s3data andUser:user andtitle:title andpostDay:postday andpublishDay:pubday];
}

/*
 * Using the pre-defined query, extracts items from the domain in a determined order using the 'select' operation.
 */
-(NSArray *)getNewses
{
    NSString *query = nil;
    
    switch (sortMethod) {
        case PLAYER_SORT: {
           // query = PUBDAY_SORT_QUERY;
            query = [Create_Query create_query:[NSDate dateWithTimeIntervalSinceNow:-86400*7]];
            break;
        }
            
        case SCORE_SORT: {
            query = USER_SORT_QUERY;
            break;
        }
            
        default: {
            query = NO_SORT_QUERY;
        }
    }
    
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc] initWithSelectExpression:query];
    selectRequest.consistentRead = YES;
    if (self.nextToken != nil) {
        selectRequest.nextToken = self.nextToken;
    }
    
    
    SimpleDBSelectResponse *selectResponse = [sdbClient select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return [NSArray array];
    }
    
    self.nextToken = selectResponse.nextToken;
    
    return [self convertItemsToNews:selectResponse.items];
}

/*
 * If a 'nextToken' was returned on the previous query execution, use the next token to get the next batch of items.
 */
-(NSArray *)getNextPageOfNews
{
    if (self.nextToken == nil) {
        return [NSArray array];
    }
    else {
        return [self getNewses];
    }
}

/*
 * Creates a new item and adds it to the HighScores domain.
 */
-(void)addNews:(News_data *)News
{
    NSString *paddedpostday = [self getPaddedDay:News.Post_Day];
    NSString *paddedpubday = [self getPaddedDay:News.Publish_Day];
    
    SimpleDBReplaceableAttribute *s3dataAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:S3DATA_ATTRIBUTE andValue:News.S3_Data andReplace:YES];
    
    SimpleDBReplaceableAttribute *titleAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:TITLE_ATTRIBUTE andValue:News.Title andReplace:YES];
    
    SimpleDBReplaceableAttribute *userAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:USER_ATTRIBUTE andValue:News.User andReplace:YES];
    
    SimpleDBReplaceableAttribute *pubdayAttribute  = [[SimpleDBReplaceableAttribute alloc] initWithName:PUBLISHDAY_ATTRIBUTE andValue:paddedpubday andReplace:YES];
    
    SimpleDBReplaceableAttribute *postdayAttribute  = [[SimpleDBReplaceableAttribute alloc] initWithName:POSTDAY_ATTRIBUTE andValue:paddedpostday andReplace:YES];
    
    NSMutableArray *attributes = [[NSMutableArray alloc] initWithCapacity:5];
    [attributes addObject:s3dataAttribute];
    [attributes addObject:titleAttribute];
    [attributes addObject:userAttribute];
    [attributes addObject:pubdayAttribute];
    [attributes addObject:postdayAttribute];
    
    SimpleDBPutAttributesRequest *putAttributesRequest = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:News.S3_Data andAttributes:attributes];
    
    SimpleDBPutAttributesResponse *putAttributesResponse = [sdbClient putAttributes:putAttributesRequest];
    if(putAttributesResponse.error != nil)
    {
        NSLog(@"Error: %@", putAttributesResponse.error);
    }
}

/*
 * Removes the item from the HighScores domain.
 * The item removes is the item whose 'player' matches the theHighScore submitted.
 */
-(void)removeNews:(News_data *)theNews
{
    @try {
        SimpleDBDeleteAttributesRequest *deleteItem = [[SimpleDBDeleteAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:theNews.S3_Data];
        [sdbClient deleteAttributes:deleteItem];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception : [%@]", exception);
    }
}

/*
 * Creates the HighScore domain.
 */
-(void)createNewsDomain
{
    SimpleDBCreateDomainRequest *createDomain = [[SimpleDBCreateDomainRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN];
    SimpleDBCreateDomainResponse *createDomainResponse = [sdbClient createDomain:createDomain];
    if(createDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", createDomainResponse.error);
    }
}

/*
 * Deletes the HighScore domain.
 */
-(void)clearNews
{
    SimpleDBDeleteDomainRequest *deleteDomain = [[SimpleDBDeleteDomainRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN];
    SimpleDBDeleteDomainResponse *deleteDomainResponse = [sdbClient deleteDomain:deleteDomain];
    if(deleteDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteDomainResponse.error);
    }
    
    SimpleDBCreateDomainRequest *createDomain = [[SimpleDBCreateDomainRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN];
    SimpleDBCreateDomainResponse *createDomainResponse = [sdbClient createDomain:createDomain];
    if(createDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", createDomainResponse.error);
    }
}

/*
 * Converts an array of Items into an array of HighScore objects.
 */
-(NSArray *)convertItemsToNews:(NSArray *)theItems
{
    NSMutableArray *highScores = [[NSMutableArray alloc] initWithCapacity:[theItems count]];
    for (SimpleDBItem *item in theItems) {
        [highScores addObject:[self convertSimpleDBItemToNews:item]];
    }
    
    return highScores;
}

/*
 * Converts a single SimpleDB Item into a HighScore object.
 */
-(News_data *)convertSimpleDBItemToNews:(SimpleDBItem *)theItem
{
    /*
     initWithNews:(NSString *)s3_Data
     andUser:(NSString *)theUser
     andtitle:(NSString *)title
     andpostDay:(NSInteger)postDay
     andpublishDat:(NSInteger)publishDay;
     */
    
    return [[News_data alloc] initWithNews:[self gets3dataFromItem:theItem]
                                    andUser:[self getuserFromItem:theItem]
                                   andtitle:[self gettitleFromItem:theItem]
                                 andpostDay:[self getpostdayFromItem:theItem]
                              andpublishDay:[self getpublishdayFromItem:theItem]];
    
}

/*
 * Extracts the 's3data' attribute from the SimpleDB Item.
 */
-(NSString *)gets3dataFromItem:(SimpleDBItem *)theItem
{
    return [self getStringValueForAttribute:S3DATA_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the 'user' attribute from the SimpleDB Item.
 */
-(NSString *)getuserFromItem:(SimpleDBItem *)theItem
{
    return [self getStringValueForAttribute:USER_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the 'title' attribute from the SimpleDB Item.
 */
-(NSString *)gettitleFromItem:(SimpleDBItem *)theItem
{
    return [self getStringValueForAttribute:TITLE_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the 'publish_day' attribute from the SimpleDB Item.
 */
-(int)getpublishdayFromItem:(SimpleDBItem *)theItem
{
    return [self getIntValueForAttribute:PUBLISHDAY_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the 'post_day' attribute from the SimpleDB Item.
 */
-(int)getpostdayFromItem:(SimpleDBItem *)theItem
{
    return [self getIntValueForAttribute:POSTDAY_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the value for the given attribute from the list of attributes.
 * Extracted value is returned as a NSString.
 */
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return attribute.value;
        }
    }
    
    return @"";
}

/*
 * Extracts the value for the given attribute from the list of attributes.
 * Extracted value is returned as an int.
 */
-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return [attribute.value intValue];
        }
    }
    
    return 0;
}

/*
 * Creates a padded number and returns it as a string.
 * All strings returned will have 10 characters.
 */
-(NSString *)getPaddedDay:(int)theDay
{
    NSString *pad        = @"0000000000";
    NSString *scoreValue = [NSString stringWithFormat:@"%d", theDay];
    
    NSRange  range;
    
    range.location = [pad length] - [scoreValue length];
    range.length   = [scoreValue length];
    
    return [pad stringByReplacingCharactersInRange:range withString:scoreValue];
}





@end
