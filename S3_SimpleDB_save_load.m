//
//  S3_SimpleDB_save_load.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/24.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "S3_SimpleDB_save_load.h"
#import "Const.h"
#import "Create_Query.h"
#import <AWSS3/AWSS3.h>

@implementation S3_SimpleDB_save_load

-(id)init
{
    self = [super init];
    if(self)
    {
        //self.Data_Arr = [[NSMutableArray alloc] init];
        [self s3sdb_init];
    }
    return self;
}

-(void)Save_Data:(NSData *)data and_props:(Save_Props *)prop
{
   
    [self s3sdb_init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        /*
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
        [df setDateFormat:@"yyMMddHHmm"];
        NSString *strNow = [df stringFromDate:[NSDate date]];
        int intDay = [strNow intValue];
         */
        
        NSString *key = [Const makeUniqueString];
        [self uploadData:data and_key:key];
        prop.s3Data = key;
        AnyData_forSimpleDB *any_data = [[AnyData_forSimpleDB alloc] initWithKeys:key andProps:prop];
        //AnyData_forSimpleDB *any_data = [[AnyData_forSimpleDB alloc] initWithKeys:key andUser:prop.user andPubday:[Const nowKeystring] and_title:prop.news_title];
        //AnyData_forSimpleDB *any_data = [[AnyData_forSimpleDB alloc] initWithData:data andMainKey:key];
       // SimpleDB_DataList  *sDB_DataList  = [[SimpleDB_DataList alloc] initWithProperties:data andMainkey:key];
        //SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
        //[self.sdb createDataDomain];
        [self.sdb addData:any_data];
    });

}

-(void )uploadData:(NSData *)data and_key:(NSString *)key
{
    
    //id ins = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self processGrandCentralDispatchUpload:data withName:key];
    
}

#pragma mark S3 upload
- (void)processGrandCentralDispatchUpload:(NSData *)Data withName:(NSString *)imgname
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:imgname
                                                                 inBucket:[Const pictureBucket]];
        por.contentType = @"image/jpeg";
        por.data        = Data;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", putObjectResponse.error);
                [self showAlertMessage:[putObjectResponse.error.userInfo objectForKey:@"message"] withTitle:@"Upload Error"];
            }
            else
            {
                [self showAlertMessage:@"The image was successfully uploaded." withTitle:@"Upload Completed"];
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)showAlertMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}



-(void)Load_Data:(NSString *)key block:(dispatch_block_t)block
{
    [self s3sdb_init];
    //SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
    AnyData_forSimpleDB *any_data = [self.sdb getS3Data:key];
    NSString *s3key = [any_data get_value:any_data.s3Data];
    [self Download_S3:s3key block:block];
}

-(void)Load_Data_Arr:(dispatch_block_t)block
{
    [self s3sdb_init];
     //SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
   // NSArray *arr = [self.sdb getNextPageOfData];
  //  int count = [self.sdb DataCount];
    NSArray *arr = [self.sdb getDatas];
    
    for (AnyData_forSimpleDB *adb in arr) {
        NSString *s3key = adb.s3Data;
        [self Download_S3:s3key block:block];
    }
   //  dispatch_sync(dispatch_get_main_queue(), block);
}

-(void)Load_Data_Arr:(dispatch_block_t)block add_query:(NSString *)query
{
    [self s3sdb_init];
    //SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
    // NSArray *arr = [self.sdb getNextPageOfData];
    //  int count = [self.sdb DataCount];
    NSArray *arr = [self.sdb getDatas:query];
    
    for (AnyData_forSimpleDB *adb in arr) {
        NSString *s3key = adb.s3Data;
        [self Download_S3:s3key block:block];
    }
    //  dispatch_sync(dispatch_get_main_queue(), block);
}
     
-(void)Download_S3:(NSString *)s3_key block:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        S3GetObjectRequest* getRequest = [[S3GetObjectRequest alloc] initWithKey:s3_key withBucket:[Const pictureBucket]];
        getRequest.contentType = @"image/jpeg";
      //  getRequest.delegate = self;
        
        S3GetObjectResponse* getResponse = [self.s3 getObject:getRequest];
       // return;
        if(getResponse == nil)
        {
            if(getResponse.error != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"Error: %@", getResponse.error);
                    [self showAlertMessage:[getResponse.error.userInfo objectForKey:@"message"] withTitle:@"Browser Error"];
                });
                
            }
            
        }
        else
        {
            NSData *down = getResponse.body;
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            [arr addObject:down];
            self.Data_Arr = arr;
            dispatch_sync(dispatch_get_main_queue(), block);
        }
        
    });
    
    
}

-(void)Clear_All_Data
{
    [self s3sdb_init];
    NSArray *arr = [self.sdb getDatas];
    
    for (AnyData_forSimpleDB *adb in arr) {
         NSString *s3key = adb.s3Data;
        [self deleteData:s3key];
    }
    
    [self.sdb clearData];
}

-(void)deleteData:(NSString *)key
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        [self.s3 deleteObjectWithKey:key withBucket:[Const pictureBucket]];
    });
}

-(void)s3sdb_init
{
    if (self.s3 == nil) {
        self.s3  = [S3_init init_S3];
    }
    AnyData_forSimpleDB *dum = [[AnyData_forSimpleDB alloc] init];
    NSArray *props = [dum propertyNames];
    self.sdb = [[SimpleDB_DataList alloc] initWithProperties:props andMainkey:nil];
}


@end
