//
//  SimpleDB_DataList.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/15.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "SimpleDB_DataList.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Const.h"
#import "Create_Query.h"

#define HIGH_SCORE_DOMAIN    @"News"

#define S3DATA_ATTRIBUTE     @"s3data"
#define USER_ATTRIBUTE       @"user"
#define PUBLISHDAY_ATTRIBUTE @"publish_day"

#define POSTDAY_ATTRIBUTE    @"post_day"
#define TITLE_ATTRIBUTE      @"title"


#define COUNT_QUERY          @"select count(*) from News"

#define PUBDAY_SORT_QUERY    @"select s3data, user, title, publish_day, post_day from News where publish_day > '140130' order by publish_day asc"
#define USER_SORT_QUERY     @"select s3data, user, title, publish_day, post_day from News where user >= '' order by user desc"
#define NO_SORT_QUERY        @"select s3data, user, title, publish_day, post_day from News"


@implementation SimpleDB_DataList

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

-(id)initWithProperties:(NSData *)archived_Data andMainkey:(NSString *)key
{
    self = [super init];
    if (self)
    {
        // Initial the SimpleDB Client.
        sdbClient      = [[AmazonSimpleDBClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sdbClient.endpoint = [AmazonEndpoints sdbEndpoint:AP_NORTHEAST_1];
        
        self.nextToken = nil;
        _archived_Data = archived_Data;
        mainKey = key;
        sortMethod     = NO_SORT;
    }
    
    return self;
}

/*
 * Method returns the number of items in the High Scores Domain.
 */
-(int)DataCount
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
-(AnyData_forSimpleDB *)getS3Data:(NSString *)one_key
{
    SimpleDBGetAttributesRequest *gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:one_key];
    SimpleDBGetAttributesResponse *response = [sdbClient getAttributes:gar];
    //[gar release];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    /*
    one_key =  [self getStringValueForAttribute:S3DATA_ATTRIBUTE fromList:response.attributes];
    NSString *title  =  [self getStringValueForAttribute:TITLE_ATTRIBUTE fromList:response.attributes];
    NSString *user   =  [self getStringValueForAttribute:USER_ATTRIBUTE fromList:response.attributes];
    int postday      =  [self getIntValueForAttribute:POSTDAY_ATTRIBUTE fromList:response.attributes];
    int pubday       =  [self getIntValueForAttribute:PUBLISHDAY_ATTRIBUTE fromList:response.attributes];
    
     */
    
    return [[AnyData_forSimpleDB alloc] initWithAttributes:response.attributes
                                              andPropNames:[self getClassProperties:_archived_Data]
                                                andMainKey:mainKey];
}

/*
 * Using the pre-defined query, extracts items from the domain in a determined order using the 'select' operation.
 */
-(NSArray *)getDatas
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
            //query = NO_SORT_QUERY;
            query = [Create_Query create_query:[self getClassProperties:_archived_Data]
                                  and_main_key:mainKey
                                   and_day_key:@"publish_day"
                                  and_last_day:[NSDate dateWithTimeIntervalSinceNow:-86400*7]];
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
    
    return [self convertItemsToData:selectResponse.items];
}

/*
 * If a 'nextToken' was returned on the previous query execution, use the next token to get the next batch of items.
 */
-(NSArray *)getNextPageOfData
{
    if (self.nextToken == nil) {
        return [NSArray array];
    }
    else {
        return [self getDatas];
    }
}

/*
 * Creates a new item and adds it to the HighScores domain.
 */
-(void)addData:(AnyData_forSimpleDB *)theData
{
    NSMutableArray *attributes = [theData get_Attribute_Array];
    
    SimpleDBPutAttributesRequest *putAttributesRequest = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:theData.Mainkey andAttributes:attributes];
    
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
-(void)removeData:(AnyData_forSimpleDB *)theData
{
    @try {
        SimpleDBDeleteAttributesRequest *deleteItem = [[SimpleDBDeleteAttributesRequest alloc] initWithDomainName:HIGH_SCORE_DOMAIN andItemName:[theData get_value:theData.Mainkey]];
        [sdbClient deleteAttributes:deleteItem];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception : [%@]", exception);
    }
}

/*
 * Creates the HighScore domain.
 */
-(void)createDataDomain
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
-(void)clearData
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
-(NSArray *)convertItemsToData:(NSArray *)theItems
{
    NSMutableArray *highScores = [[NSMutableArray alloc] initWithCapacity:[theItems count]];
    for (SimpleDBItem *item in theItems) {
        [highScores addObject:[self convertSimpleDBItemToData:item]];
    }
    
    return highScores;
}

/*
 * Converts a single SimpleDB Item into a HighScore object.
 */
-(AnyData_forSimpleDB *)convertSimpleDBItemToData:(SimpleDBItem *)theItem
{
    /*
     initWithNews:(NSString *)s3_Data
     andUser:(NSString *)theUser
     andtitle:(NSString *)title
     andpostDay:(NSInteger)postDay
     andpublishDat:(NSInteger)publishDay;
     */
    
    
    return [[AnyData_forSimpleDB alloc] initWithSimpleDBItem:theItem
                                                andPropNames:[self getClassProperties:_archived_Data]
                                                andMainKey:mainKey];
    
}

-(NSArray *)getClassProperties:(NSData *)archived_Data
{
    id any_instanse = [NSKeyedUnarchiver unarchiveObjectWithData:archived_Data];
    return [any_instanse propertyNames];
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
