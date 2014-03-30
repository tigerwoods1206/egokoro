//
//  Save_Props.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/10.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Codable.h"
#import "UIImage+Text.h"

@interface Save_Props : Codable

@property NSString *user;
@property NSString *news_title;
@property NSString *Pubday;
@property NSString *s3Data;
@property NSString *category;
@property NSString *hpadress;

-(void)set_ImageText:(UIImage_Text *)imgtxt;

@end
