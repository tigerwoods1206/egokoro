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

@interface UIImage_Text : Codable

@property UIImage  *image;
@property NSString *text;
@property NSString *news_title;

@end
