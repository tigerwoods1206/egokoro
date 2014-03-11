//
//  News_Cell.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/13.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "News_Cell.h"
#import "Imagetext_save_load.h"
#import "AWS_Image_save_load.h"

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

-(void)setNewsItem:(Item *)NewsItem
{
    self.NewsTitle.text  = NewsItem.title;
    self.NewsImage.image = NewsItem.news_image;
    self.NewsDay.text    = NewsItem.date;
    self.NewsDetail.text = NewsItem.description;
    
    if ( NewsItem.news_image!=nil) {
        [self.NewsImage setImage:NewsItem.news_image];
        self.NewsImage.contentMode = UIViewContentModeScaleAspectFill;
        self.NewsImage.clipsToBounds = YES;
    }
    else {
        [self load_set_AWSImage:self.NewsTitle.text errorBlock:nil];
    }
}

-(void)setNewsTitleText:(NSString *)NewsTitleText
{
    Img_sl = [[Imagetext_save_load alloc] init];
    UIImage_Text *it = [Img_sl getImageText:NewsTitleText];
    self.NewsTitle.text = NewsTitleText;
    self.NewsImage.image = nil;
    if (it!=nil && it.image!=nil) {
        [self.NewsImage setImage:it.image];
        self.NewsImage.contentMode = UIViewContentModeScaleAspectFill;
        self.NewsImage.clipsToBounds = YES;
    }
}

-(void) load_set_AWSImage:(NSString *)title errorBlock:(dispatch_block_t)errorBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        AWS_Image_save_load *awssl = [[AWS_Image_save_load alloc] init];
        [awssl getImageArray_with_title:title add_block:
         ^{
             
             
             NSArray *imgarr = awssl.S3sdb.Data_Arr;
             int rand_num = random() % [imgarr count];
             
             int i_count = 0;
             for (NSData *cur_imgtxt_data in imgarr) {
                 if (i_count == rand_num) {
                     UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:cur_imgtxt_data];
                     [self.NewsImage setImage:imgtxt.image];
                     //[self setNeedsLayout];
                     break;
                 }
                 i_count++;
             }
             
             // dispatch_sync(dispatch_get_main_queue(), block);
         }
         ];
        
    });
}


@end
