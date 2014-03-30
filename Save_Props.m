//
//  Save_Props.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/10.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Save_Props.h"

@implementation Save_Props

-(void)set_ImageText:(UIImage_Text *)imgtxt
{
    self.user       = imgtxt.user;
    self.news_title = imgtxt.news_title;
    self.Pubday     = imgtxt.pub_day;
    self.category   = imgtxt.category;
    self.hpadress   = imgtxt.hpadress;
}

@end
