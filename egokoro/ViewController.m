//
//  ViewController.m
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/07.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import "ViewController.h"
#import "News_Paper_View.h"
#import "AnimationController.h"
#import "HHTabListController.h"
#import "XMLReader.h"
#import "ASIHTTPRequest.h"
#import "Url_content.h"
#import "Item.h"
#import "News_Cell.h"
#import "Imagetext_save_load.h"

@interface ViewController () <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>
{
    Item *_item;
    NSXMLParser *_parser;
    NSDictionary *dicinfo;
    UIRefreshControl *refreshControl;
    AnimationController *_animationController;
    int News_Get_Flag;
}
-(void)receiveInfo;
-(void)receiveInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    m_View    = nil;
    m_TblView = nil;
    
    m_rcMainSrcn = [[UIScreen mainScreen] applicationFrame];
    m_notframSrcn = [[UIScreen mainScreen] bounds];
    
    [self initView:@"main" withColor:[UIColor grayColor]];
    self.navigationController.delegate = self;
    
    //news flag
    News_Get_Flag = NEW_NEWS;
    
    //refresh cont
    
    _items = [[NSMutableArray alloc] init];
    
    [self receiveInfoWithCompletedBlock:^{
        [m_TblView reloadData];
    } errorBlock:nil];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(receiveInfo)
             forControlEvents:UIControlEventValueChanged];
    [m_TblView addSubview:refreshControl];
    
    //init Custum Cell
    UINib *nib = [UINib nibWithNibName:@"News_View" bundle:nil];
    [m_TblView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    // アニメーションを管理するクラス
    _animationController =[[AnimationController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([self isMovingToParentViewController]) {
		HHTabListController *tabListController = [self tabListController];
		UIBarButtonItem *leftBarButtonItem = tabListController.revealTabListBarButtonItem;
		
		self.navigationItem.leftBarButtonItem = leftBarButtonItem;
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView:title withColor:(UIColor *)color
{
    // UIView
    m_View = [[UIView alloc] initWithFrame:CGRectMake(0,  m_rcMainSrcn.origin.y, m_rcMainSrcn.size.width, m_rcMainSrcn.size.height-TABBAR_HEIGHT)];
    [m_View setBackgroundColor:color];
    [self.view addSubview:m_View];
    
    // UITableView
    m_TblView = [[UITableView alloc] initWithFrame:CGRectMake( 0, NAVIGATIONBAR_HEIGHT - 15 + AD_HEIGHT,
                                                              m_rcMainSrcn.size.width,
                                                              m_rcMainSrcn.size.height-NAVIGATIONBAR_HEIGHT-TABBAR_HEIGHT - AD_HEIGHT + 15)
                                             style:UITableViewStyleGrouped];
    [m_TblView setBackgroundColor:[UIColor clearColor]];
    [m_TblView setBackgroundView:nil];
     
    m_TblView.delegate = self;
    m_TblView.dataSource = self;
    
    
    
    UIEdgeInsets insets = m_TblView.contentInset;
    insets.top -= m_rcMainSrcn.origin.y;
    m_TblView.contentInset = insets;

    [m_View addSubview:m_TblView];

    [self init_UIToolBar];

}

-(void)init_UIToolBar
{
    menuToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, m_rcMainSrcn.size.height-TABBAR_HEIGHT,
                                                              m_rcMainSrcn.size.width, TABBAR_HEIGHT)];
    
    // ボタンを作成する
    UIBarButtonItem * btn1 = [ [ UIBarButtonItem alloc ] initWithTitle:@"User_News" style:UIBarButtonItemStyleBordered target:self action:@selector( go_user_news: ) ];
    UIBarButtonItem * btn2 = [ [ UIBarButtonItem alloc ] initWithTitle:@"My_News" style:UIBarButtonItemStyleBordered target:self action:@selector( go_my_news: ) ];
    UIBarButtonItem * btn3 = [ [ UIBarButtonItem alloc ] initWithTitle:@"Get_News" style:UIBarButtonItemStyleBordered target:self action:@selector( go_new_news: ) ];
    //    UIBarButtonItem * btn3 = [ [ UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector( do_navigate: ) ];
    // ボタン配列をツールバーに設定する
    menuToolBar.items = [ NSArray arrayWithObjects:btn1, btn2, btn3, nil ];
    [self.view addSubview:menuToolBar];
}

-(void)go_user_news:(id)sender
{
     News_Get_Flag = USER_NEWS;
    [self receiveInfo];
}
-(void)go_my_news:(id)sender
{
    News_Get_Flag = MY_NEWS;
    [self receiveInfo];
}


-(void)go_new_news:(id)sender
{
     News_Get_Flag = NEW_NEWS;
    [self receiveInfo];
}

#pragma mark private method
#pragma mark --get cell data
-(void)receiveInfo
{
    if ( News_Get_Flag == NEW_NEWS) {
        [self receiveInfoWithCompletedBlock:^{
            [m_TblView reloadData];
            [refreshControl endRefreshing];
        } errorBlock:nil];
    }
    else if (News_Get_Flag == MY_NEWS) {
        [self loadInfoWithCompletedBlock:^{
            [m_TblView reloadData];
            [refreshControl endRefreshing];
        } errorBlock:nil];
    }
    else { // USER_NEWS
        [self loadInfoWithCompletedBlock:^{
            [m_TblView reloadData];
            [refreshControl endRefreshing];
        } errorBlock:nil];
    }
}

-(void) loadInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
         //_items = [[NSMutableArray alloc] initWithArray:tmp_items];
         [_items removeAllObjects];
         Imagetext_save_load *isl = [[Imagetext_save_load alloc] init];
         NSArray *imgtxt_arr = [isl getImageArray];
         for (UIImage_Text *cur_imgtxt in imgtxt_arr) {
             //Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
             Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
             tmp_item.title       = cur_imgtxt.news_title;
             tmp_item.description = cur_imgtxt.text;
             [_items addObject:tmp_item];
         }
         dispatch_sync(dispatch_get_main_queue(), block);
     });
}

#pragma mark --get cell info from web api
-(void) receiveInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //NSURL *url = [NSURL URLWithString:@"http://headlines.yahoo.co.jp/rss/all-c_int.xml"];
        NSURL *url = [NSURL URLWithString:self.news_address];
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
            Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
            
            NSDictionary *chan_title = [one_chan valueForKey:@"title"];
            NSString *title = [chan_title valueForKey:@"text"];
            
            NSDictionary *pubDate = [one_chan valueForKey:@"pubDate"];
            NSString *str_date = [pubDate valueForKey:@"text"];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            NSLocale *locale_en = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [formatter setLocale:locale_en];
            [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
            NSDate *date = [formatter dateFromString:str_date];
            
            NSLocale *locale_jp = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
            [formatter setLocale:locale_jp];
            [formatter setDateFormat:@"M月dd日 HH時mm分"];
            NSString *str_date_jpn = [formatter stringFromDate:date];
            NSLog(@"%@",str_date_jpn);
            
            for (Item *one_item in _items) {
                if (([title compare:one_item.title] == NSOrderedSame) &&
                    (one_item.description != nil)){
                    tmp_item.description = one_item.description;
                    tmp_item.date = one_item.date;
                    set_description_flg = FALSE;
                    break;
                }
            }
            
            tmp_item.title = title;
            tmp_item.date = str_date_jpn;
            
            if (set_description_flg) {
                //_item.description = @"";
                NSDictionary *channel_link_ar = [one_chan valueForKey:@"link"];
                NSString *channel_link = [channel_link_ar valueForKey:@"text"];
                [Url_content get_content_form_url:channel_link reload_table:m_TblView setitem:tmp_item];
            }
            
            [tmp_items addObject:tmp_item];
        }
        
        [_items removeAllObjects];
        _items = [[NSMutableArray alloc] initWithArray:tmp_items];
        dispatch_sync(dispatch_get_main_queue(), block);
    });
}


#pragma mark - tableviewcont delegate
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
    NSString *cellIdentifier = @"Cell";
    News_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Item *item = _items[indexPath.row];
//    if (!cell) { // yes
//        // セルを作成
//        cell = [[News_Cell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//    }
    
    //cell.contentView
    //cell.NewsTitle.text  = [item title];
    [cell setNewsTitleText:[item title]];
    cell.NewsDay.text    = [item date];
    cell.NewsDetail.text = [item description];
    //[cell.NewsDetail cutOutframeText];

//    cell.textLabel.text = [item title];
//    cell.detailTextLabel.text = [item description];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 128.0f;
   
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    News_Paper_View *news_view = [[News_Paper_View alloc] init];
    Item *item = _items[indexPath.row];
   // NSLog(@"%s",item.description);
    [news_view set_text:item.description];
    [news_view set_newstitle:item.title];

    [self.navigationController pushViewController:news_view animated:YES];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return _animationController;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    // 画面遷移の状態によってアニメーションの向きを変える
    _animationController.isReverse = operation == UINavigationControllerOperationPop;
    
    return _animationController;
}


@end
