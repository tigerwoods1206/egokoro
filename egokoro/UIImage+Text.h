//
//  UIImage+Text.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/19.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Codable.h"
//#import "Save_Props.h"

@interface UIImage_Text : Codable

@property UIImage  *image;
@property NSString *pub_day;
@property NSString *text;
@property NSString *news_title;
@property NSString *user;
@property NSString *category;
@property NSString *hpadress;

//@property Save_Props *props;

@end
