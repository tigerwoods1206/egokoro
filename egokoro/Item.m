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

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"description"];
}

@end