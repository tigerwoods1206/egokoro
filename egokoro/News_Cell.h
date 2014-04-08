//
//  News_Cell.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/13.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageTextView.h"
#import "Item.h"

@interface News_Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *NewsTitle;
@property (weak, nonatomic) IBOutlet UILabel *NewsDay;
@property (weak, nonatomic) IBOutlet UIImageTextView *NewsDetail;
//@property (weak, nonatomic) IBOutlet UILabel *NewsUser;
//@property (weak, nonatomic) IBOutlet UILabel *NewsUserTitle;
@property (weak, nonatomic) IBOutlet UIImageView *NewsImage;

@property (nonatomic, strong) Item *NewsItem;

@end
