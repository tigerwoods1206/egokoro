//
//  Url_content.h
//  NewsReader
//
//  Created by オオタ イサオ on 2013/12/23.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface Url_content : NSObject

+(void)get_content_form_url:(NSString *)urlstring reload_table:(UITableView *)tableview setitem:(Item *)item;
@end
