//
//  MasterViewController.h
//  NewsReader
//
//  Created by Dolice on 2013/03/02.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "item.h"
#import "XMLReader.h"
#import "ASIHTTPRequest.h"

@interface MasterViewController : UITableViewController <NSXMLParserDelegate>
{
    
}
@property(retain)  NSMutableArray *items;

@end
