//
//  Item.h
//  NewsReader
//
//  Created by Dolice on 2013/03/02.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Text.h"

@interface Item : NSObject
{
    UITableView *my_tableview;
}
@property NSString *title;
@property NSString *date;
@property NSString *description;
@property UIImage  *news_image;
@property (nonatomic,retain) UIImage_Text *News_imagetext;

-(id)initWithTable:(UITableView *)tableview;

@end
