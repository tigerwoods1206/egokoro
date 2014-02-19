//
//  Item.h
//  NewsReader
//
//  Created by Dolice on 2013/03/02.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
{
    UITableView *my_tableview;
}
@property NSString *title;
@property NSString *date;
@property NSString *description;

-(id)initWithTable:(UITableView *)tableview;

@end
