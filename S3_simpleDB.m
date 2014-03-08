//
//  S3_simpleDB.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/14.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "S3_simpleDB.h"
#import "SimpleDB_DataList.h"
#import "Const.h"

@implementation S3_simpleDB

-(id)init
{
    self = [super init];
    if (self)
    {
        if (s3 == nil) {
            s3 = [S3_init init_S3];
        }
    }
    
    return self;
}


-(void )uploadData:(NSData *)data
{
    
    //id ins = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *key = [Const makeUniqueString];
    
    [self processGrandCentralDispatchUpload:data withName:key];
    
}

#pragma mark - private method

#pragma mark - SimpleDB Upload
- (void)simpleDB_Upload:(NSData *)data
{
   // Example *example2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]]; // Localeの指定
        [df setDateFormat:@"yyMMddHHmm"];
        NSString *strNow = [df stringFromDate:[NSDate date]];
        int intDay = [strNow intValue];
        /*
        News_data  *highScore  = [[News_data alloc] initWithNews:s3data.text
                                                         andUser:user.text
                                                        andtitle:s3data.text
                                                      andpostDay:intDay
                                                   andpublishDay:intDay
                                  ];
        News_List *highScoreList = [[News_List alloc] init];
        [highScoreList addNews:highScore];
        */
        //AnyData_forSimpleDB *any_data = [[AnyData_forSimpleDB alloc] initWithData:data andMainKey:key];
        // SimpleDB_DataList  *sDB_DataList  = [[SimpleDB_DataList alloc] initWithProperties:data andMainkey:key];
        SimpleDB_DataList *sDB_DataList = [[SimpleDB_DataList alloc] init];
        //[sDB_DataList addData:any_data];
    });

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
        S3PutObjectResponse *putObjectResponse = [s3 putObject:por];
        
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


@end
