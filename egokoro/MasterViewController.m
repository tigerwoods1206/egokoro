//
//  MasterViewController.m
//  NewsReader
//
//  Created by 高橋京介 on 2012/11/03.
//  Copyright (c) 2012年 mycompany. All rights reserved.
//

#import "MasterViewController.h"
//#import "DetailViewController.h"
#import "Url_content.h"

@interface MasterViewController () {
  //  NSMutableArray *_items;
    Item *_item;
    NSXMLParser *_parser;
    NSString *_elementName;
    NSDictionary *dicinfo;
    UIRefreshControl *refreshControl;
}

-(void)receiveInfo;
-(void)receiveInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock;
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _items = [[NSMutableArray alloc] init];
    [self receiveInfoWithCompletedBlock:^{
        [self.tableView reloadData];
    } errorBlock:nil];

    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(receiveInfo)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Item *item = _items[indexPath.row];
    cell.textLabel.text = [item title];
    cell.detailTextLabel.text = [item description];
    return cell;
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Item *item = _items[indexPath.row];
        [[segue destinationViewController] setDetailItem:item];
    }
}
*/

-(void)receiveInfo
{
    [self receiveInfoWithCompletedBlock:^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    } errorBlock:nil];
}

-(void) receiveInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://headlines.yahoo.co.jp/rss/all-c_int.xml"];
        ASIHTTPRequest *request;
        NSError *err;
        
        request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request startSynchronous];
        err = [request error];
        if (err) {
            dispatch_sync(dispatch_get_main_queue(), errorBlock);
            return ;
        }
        dicinfo = [XMLReader dictionaryForXMLData:request.responseData error:&err];
        NSArray *rss_array     = [dicinfo valueForKey:@"rss"];
        NSArray *channel_array = [rss_array valueForKey:@"channel"];
        NSArray *channel_items = [channel_array valueForKey:@"item"];
        
        NSMutableArray *tmp_items = [[NSMutableArray alloc] init];
        int set_description_flg;
        for (NSArray *one_chan in channel_items) {
            
            set_description_flg = TRUE;
            _item = [[Item alloc] initWithTable:self.tableView];
           
            NSDictionary *chan_title = [one_chan valueForKey:@"title"];
            NSString *title = [chan_title valueForKey:@"text"];
            
            for (Item *one_item in _items) {
                if (([title compare:one_item.title] == NSOrderedSame) &&
                    (one_item.description != nil)){
                    _item.description = one_item.description;
                    set_description_flg = FALSE;
                    break;
                }
            }
          
            _item.title = title;
            if (set_description_flg) {
                _item.description = @"";
                NSDictionary *channel_link_ar = [one_chan valueForKey:@"link"];
                NSString *channel_link = [channel_link_ar valueForKey:@"text"];
                [Url_content get_content_form_url:channel_link reload_table:self.tableView setitem:_item];
            }
        
            [tmp_items addObject:_item];
        }
        
         _items = [[NSMutableArray alloc] initWithArray:tmp_items];
        dispatch_sync(dispatch_get_main_queue(), block);
    });
}

@end
