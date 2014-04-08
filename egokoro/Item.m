//
//  Item.m
//  NewsReader
//
//  Created by Dolice on 2013/03/02.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import "Item.h"
#import "News_Cell.h"

@implementation Item

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
// temp
    return;
    if([keyPath isEqualToString:@"description"]) {
        NSLog(@"observed");   // nameプロパティの値が取れる
        NSString *desc = [object valueForKey:@"description"];
        if (desc == nil) {
            return;
        }
        if (my_tableview != nil) {
            //[my_tableview reloadData];
            
            NSInteger max_section = [my_tableview numberOfSections];
            NSInteger max_row;
            
            for (int cur_section= 0; cur_section < max_section; cur_section++) {
                max_row = [my_tableview numberOfRowsInSection:cur_section];
                for (int cur_row = 0; cur_row < max_row; cur_row++) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:cur_row inSection:cur_section];
                    
                    News_Cell *cell = [my_tableview cellForRowAtIndexPath:indexPath];
                    NSString *detailtext = cell.textLabel.text;
                    if ([detailtext compare:self.title]== NSOrderedSame) {
                        //NSString *news_text = cell.detailTextLabel.text;
                        cell.detailTextLabel.text = desc;
                        NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
                        /*
                        UIImage_Text *img_text = [csl_ins getImageText:self.title];
                        cell.NewsDetail.text = desc;
                        if (img_text!=nil) {
                             [cell.NewsDetail setDrawImage:img_text.image];
                        }
                       */
                        [my_tableview reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
            
            
        }
    }
}
-(id)initWithTable:(UITableView *)tableview
{
    self = [super init];
    if(self != nil){
        NSLog(@"super init");
    }
    
    //- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
    
    my_tableview = tableview;
    
    [self addObserver:self  // [1] 監視者
           forKeyPath:@"description" // [2] 監視対象のキー値
              options:NSKeyValueObservingOptionNew // [3] オプションの指定
              context:nil]; //[4] 任意のオブジェクトを指定

    return self;
}

-(void)setNews_imagetext:(UIImage_Text *)news_imagetext
{
    self.title       = news_imagetext.news_title;
    self.description = news_imagetext.text;
    self.news_image  = news_imagetext.image;
    self.date        = news_imagetext.pub_day;
    self.user        = news_imagetext.user;
    self.category    = news_imagetext.category;
    self.hpaddress   = news_imagetext.hpadress;
   // self.props       = news_imagetext.props;
}

-(void)set_OtherNewsItem:(Item *)item
{
    self.title       = item.title;
    self.description = item.description;
    self.news_image  = item.news_image;
    self.date        = item.date;
    self.user        = item.user;
    self.category    = item.category;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"description"];
}

#pragma -mark private

-(void)reloadCell:(NSString *)desc
{
    NSInteger max_section = [my_tableview numberOfSections];
    NSInteger max_row;
    
    for (int cur_section= 0; cur_section < max_section; cur_section++) {
        max_row = [my_tableview numberOfRowsInSection:cur_section];
        for (int cur_row = 0; cur_row < max_row; cur_row++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:cur_row inSection:cur_section];
            
            News_Cell *cell = [my_tableview cellForRowAtIndexPath:indexPath];
            NSString *detailtext = cell.NewsTitle.text;
            if ([detailtext compare:self.title]== NSOrderedSame) {
                //NSString *news_text = cell.detailTextLabel.text;
                cell.NewsDetail.text = desc;
                [cell setNeedsDisplay];
                //NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
                /*
                 UIImage_Text *img_text = [csl_ins getImageText:self.title];
                 cell.NewsDetail.text = desc;
                 if (img_text!=nil) {
                 [cell.NewsDetail setDrawImage:img_text.image];
                 }
                 */
                //[my_tableview reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }

}


@end