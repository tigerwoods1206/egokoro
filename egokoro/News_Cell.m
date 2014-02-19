//
//  News_Cell.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/13.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "News_Cell.h"
#import "Imagetext_save_load.h"

@interface News_Cell ()
{
    Imagetext_save_load *Img_sl;
}
@end

@implementation News_Cell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setNewsTitleText:(NSString *)NewsTitleText
{
    Img_sl = [[Imagetext_save_load alloc] init];
    UIImage_Text *it = [Img_sl getImageText:NewsTitleText];
    self.NewsTitle.text = NewsTitleText;
    if (it!=nil && it.image!=nil) {
        [self.NewsImage setImage:it.image];
        self.NewsImage.contentMode = UIViewContentModeScaleAspectFill;
        self.NewsImage.clipsToBounds = YES;
    }
}

@end
