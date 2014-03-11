//
//  Save_Props.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/10.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Codable.h"

@interface Save_Props : Codable

@property NSString *user;
@property NSString *news_title;
@property NSString *Pubday;
@property NSString *s3Data;

@end
