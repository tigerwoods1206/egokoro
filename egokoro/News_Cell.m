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
    int Wait_Time;
}
@end

@implementation News_Cell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //　       Wait_Time = 0;
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
    if (NewsItem.user != nil) {
     //   self.NewsUser.text      = NewsItem.user;
      //  self.NewsUserTitle.text = @"記者:";
    }
    
    if ( NewsItem.news_image !=nil) {
        [self.NewsImage setImage:NewsItem.news_image];
        self.NewsImage.contentMode = UIViewContentModeScaleAspectFill;
        self.NewsImage.clipsToBounds = YES;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }
    else {
        if(self.NewsImage.image==nil){
            [self load_set_AWSImage:self.NewsTitle.text errorBlock:nil];
        }
    }
}

- (void)set_ImageText:(UIImage_Text *)imgtxt
{
    self.NewsDetail.text    = imgtxt.text;
    //self.NewsUser.text      = imgtxt.user;
    self.NewsDay.text       = imgtxt.pub_day;
    self.NewsTitle.text     = imgtxt.news_title;
   // self.NewsUserTitle.text = @"記者:";
    [self.NewsImage setImage:imgtxt.image];
}

-(void) load_set_AWSImage:(NSString *)title errorBlock:(dispatch_block_t)errorBlock{
    Img_sl = [[Imagetext_save_load alloc] init];
    UIImage_Text *get_img_text =  [Img_sl getImageText:self.NewsTitle.text];
    if (get_img_text!=nil) {
        [self set_ImageText:get_img_text];
        [self setNeedsLayout];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        AWS_Image_save_load *awssl = [[AWS_Image_save_load alloc] init];
        [awssl getImageArray_with_title:title add_block:
         ^{
             /*
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
             });
              */

             NSArray *imgarr = awssl.S3sdb.Data_Arr;
             int count = [imgarr count];
             if (count==0) {
                 return;
             }
             int rand_num = random() % [imgarr count];
             
             int i_count = 0;
             for (NSData *cur_imgtxt_data in imgarr) {
                 if (i_count == rand_num) {
                     UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:cur_imgtxt_data];
                     [self set_ImageText:imgtxt];
                     
                     [Img_sl setImageText:imgtxt and_key:self.NewsTitle.text];
                     [self setNeedsLayout];
                    // Wait_Time = 20;
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
