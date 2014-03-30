//
//  Item.h
//  NewsReader
//
//  Created by Dolice on 2013/03/02.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage+Text.h"
//#import "Save_Props.h"

@interface Item : NSObject
{
    UITableView *my_tableview;
}
@property NSString *title;
@property NSString *date;
@property NSString *description;
@property NSString *user;
@property UIImage  *news_image;
@property NSString *category;
@property NSString *hpaddress;
//@property(nonatomic,retain) Save_Props *props;

@property (nonatomic,retain) UIImage_Text *News_imagetext;

-(void)set_OtherNewsItem:(Item *)item;

-(id)initWithTable:(UITableView *)tableview;

@end
