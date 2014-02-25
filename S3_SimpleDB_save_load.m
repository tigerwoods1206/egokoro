//
//  S3_SimpleDB_save_load.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/24.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "S3_SimpleDB_save_load.h"
#import "SimpleDB_DataList.h"
#import "Const.h"
#import "Create_Query.h"

@implementation S3_SimpleDB_save_load

-(id)init
{
    self = [super init];
    if(self)
    {
        self.s3 = [S3_init init_S3];
    }
    return self;
}

-(void)Save_Data:(NSData *)data
{
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
        
        AnyData_forSimpleDB *any_data = [[AnyData_forSimpleDB alloc] initWithData:data andMainKey:key];
       // SimpleDB_DataList  *sDB_DataList  = [[SimpleDB_DataList alloc] initWithProperties:data andMainkey:key];
        SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
        [sDB_DataList addData:any_data];
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



-(NSData *)Load_Data:(NSString *)key
{
    SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
    AnyData_forSimpleDB *any_data = [sDB_DataList getS3Data:key];
    NSString *s3key = [any_data get_value:key];
   // [self.s3
    return nil;
}

     
-(NSData *)Download_S3:(NSString *)s3_key
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        S3GetObjectRequest* getRequest = [[S3GetObjectRequest alloc] initWithKey:s3_key withBucket:[Const pictureBucket]];
        getRequest.contentType = @"image/jpeg";
        // getRequest.delegate = self;
        
        S3GetObjectResponse* getResponse = [self.s3 getObject:getRequest];
        
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
            //  NSLog(@"%@",getResponse.body);
            /*
             UIImage* down = [[UIImage alloc] initWithData:getResponse.body];
             [uimgv setImage:down];
             */
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display the URL in Safari
                // [[UIApplication sharedApplication] openURL:url];
                UIImage* down = [[UIImage alloc] initWithData:getResponse.body];
               // [uimgv setImage:down];
            });
            
        }
        
    });
    
    
}



@end
