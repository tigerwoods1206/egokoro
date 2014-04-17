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
#import "AWS_Image_save_load.h"
#import "SVProgressHUD.h"
#import "Custum_SimpleDB.h"

@interface ViewController () <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>
{
    Item *_item;
    NSXMLParser *_parser;
    NSDictionary *dicinfo;
    UIRefreshControl *refreshControl;
    AnimationController *_animationController;
    News_Paper_View *News_view;
    int News_Get_Flag;
    int DrawButton_Flag;
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
    
    [self initView:@"main" withColor:[UIColor whiteColor]];
    self.navigationController.delegate = self;
    
    //ad
    _bannerView = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            m_rcMainSrcn.size.height-TABBAR_HEIGHT - GAD_SIZE_320x50.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    
    // ここで、AdMobパブリッシャーID ではなく AdMobメディエーションID を設定する
    _bannerView.adUnitID = MY_BANNER_UNIT_ID;
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する。
    _bannerView.rootViewController = self;
    _bannerView.delegate = self;
    
    [self.view addSubview:_bannerView];
    
    // 一般的なリクエストを行って広告を読み込む。
    [_bannerView loadRequest:[GADRequest request]];

    
    //news flag
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setNews_Get_Flag:app.NEWS_FLAG];
    
    //refresh cont
    
    _items = [[NSMutableArray alloc] init];
    
    //init Custum Cell
    UINib *nib = [UINib nibWithNibName:@"News_View" bundle:nil];
    [m_TblView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    
    if([self.news_address compare:@"IINE_RANKING"]==NSOrderedSame){
        News_Get_Flag = USER_RANKING;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.news_address = app.hpaddress;
        //self.title        = app.title;
      //  [self setNews_Get_Flag:News_Get_Flag];
    }
    
    
    // アニメーションを管理するクラス
    _animationController =[[AnimationController alloc] init];
    
    News_view = [[News_Paper_View alloc] init];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(receiveInfo)
             forControlEvents:UIControlEventValueChanged];
    [m_TblView addSubview:refreshControl];
    
    [self receiveInfo];

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
    /*
    m_TblView = [[UITableView alloc] initWithFrame:CGRectMake( 0, NAVIGATIONBAR_HEIGHT - 15 + AD_HEIGHT,
                                                              m_rcMainSrcn.size.width,
                                                              m_rcMainSrcn.size.height-NAVIGATIONBAR_HEIGHT-TABBAR_HEIGHT - AD_HEIGHT + 15)
                                             style:UITableViewStyleGrouped];
     */
    m_TblView = [[UITableView alloc] initWithFrame:CGRectMake( 0, m_rcMainSrcn.origin.y - 15 -NAVIGATIONBAR_HEIGHT,
                                                              m_rcMainSrcn.size.width,
                                                              m_rcMainSrcn.size.height + 15 -TABBAR_HEIGHT-AD_HEIGHT)
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
    
    DrawButton_Flag = TRUE;

}

-(void)init_UIToolBar
{
    menuToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, m_rcMainSrcn.size.height-TABBAR_HEIGHT,
                                                              m_rcMainSrcn.size.width, TABBAR_HEIGHT)];
    
    // ボタンを作成する
    UIBarButtonItem * btn1 = [ [ UIBarButtonItem alloc ] initWithTitle:@"ニュース見る" style:UIBarButtonItemStyleBordered target:self action:@selector( go_user_news: ) ];
    UIBarButtonItem * btn2 = [ [ UIBarButtonItem alloc ] initWithTitle:@"My_News" style:UIBarButtonItemStyleBordered target:self action:@selector( go_my_news: ) ];
    UIBarButtonItem * btn3 = [ [ UIBarButtonItem alloc ] initWithTitle:@"投稿する" style:UIBarButtonItemStyleBordered target:self action:@selector( go_new_news: ) ];
     UIBarButtonItem *btn4 = [ [ UIBarButtonItem alloc ] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector( clear: ) ];
    //    UIBarButtonItem * btn3 = [ [ UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector( do_navigate: ) ];
    // ボタン配列をツールバーに設定する
    menuToolBar.items = [ NSArray arrayWithObjects:btn1, btn3, nil ];
    [self.view addSubview:menuToolBar];
}

#pragma mark UITOOLBAR button method
-(void)go_user_news:(id)sender
{
    [self setNews_Get_Flag:USER_NEWS];
    News_Get_Flag = USER_NEWS;
    [self receiveInfo];
}
-(void)go_my_news:(id)sender
{
    [self setNews_Get_Flag:MY_NEWS];
    //_News_Get_Flag = MY_NEWS;
    [self receiveInfo];
}

-(void)go_new_news:(id)sender
{
    [self setNews_Get_Flag:NEW_NEWS];
    //_News_Get_Flag = NEW_NEWS;
    [self receiveInfo];
    
}

-(void)clear:(id)sender
{
    AWS_Image_save_load *awssl = [[AWS_Image_save_load alloc] init];
    [awssl.S3sdb Clear_All_Data];
    Imagetext_save_load *imgsl = [[Imagetext_save_load alloc] init];
    [imgsl delAllImage];
    News_Get_Flag = USER_NEWS;
    [self receiveInfo];
}

#pragma mark setter News_Get_Flag
-(void)setNews_Get_Flag:(int)flag
{
    News_Get_Flag= flag;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.NEWS_FLAG = flag;
    
    DrawButton_Flag = YES;
    if(News_Get_Flag != NEW_NEWS){
        DrawButton_Flag = NO;
    }
    [News_view set_DrawButton_enabled:DrawButton_Flag];
}

#pragma mark private method
#pragma mark --get cell data
-(void)receiveInfo
{
    [SVProgressHUD showWithStatus:@"Waiting..."
                         maskType:SVProgressHUDMaskTypeGradient];

    if ( News_Get_Flag == NEW_NEWS) {
        [self receiveInfoWithCompletedBlock:^{
            [m_TblView reloadData];
            [refreshControl endRefreshing];
            [SVProgressHUD dismiss];
        } errorBlock:nil];
    }
    else if (News_Get_Flag == MY_NEWS) {
        [self loadInfoWithCompletedBlock:^{
            [m_TblView reloadData];
            [refreshControl endRefreshing];
            [SVProgressHUD dismiss];
        } errorBlock:nil];
    }
    else if (News_Get_Flag == USER_RANKING){
        [self loadInfo_RANKING_WithCompletedBlock:^{
            
        } errorBlock:nil];
    }
    else { // USER_NEWS
        [self loadInfo_AWS_WithCompletedBlock:^{

        } errorBlock:nil];
    }
}


#pragma mark --get cell info from AWS S3 and SimpleDB
-(void) loadInfo_AWS_WithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //_items = [[NSMutableArray alloc] initWithArray:tmp_items];
        [_items removeAllObjects];
        AWS_Image_save_load *awssl = [[AWS_Image_save_load alloc] init];//getImageArray_with_category
        [awssl getImageArray_with_category:self.title add_block:
         ^{
             NSArray *imgarr = awssl.S3sdb.Data_Arr;
             NSArray *sort_imgarr = [awssl rand_sort:imgarr];
             NSMutableArray *title_arr = [[NSMutableArray alloc] init];
             for (NSData *cur_imgtxt_data in sort_imgarr) {
                 //Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
                 Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
                 UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:cur_imgtxt_data];
                 
                 if ([self strcmp_in_arr:imgtxt.news_title in_arr:title_arr]) {
                     continue;
                 }
                 
                 [title_arr addObject:imgtxt.news_title];
                 
                 [tmp_item setNews_imagetext:imgtxt];
                 [_items addObject:tmp_item];
             }
             [m_TblView reloadData];
             [refreshControl endRefreshing];
             [SVProgressHUD dismiss];
           // dispatch_sync(dispatch_get_main_queue(), block);
         }
         ];
        
    });
}

#pragma mark --get cell info from AWS S3 and SimpleDB
-(void) loadInfo_RANKING_WithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //_items = [[NSMutableArray alloc] initWithArray:tmp_items];
        [_items removeAllObjects];
        
        AWS_Image_save_load *awssl = [[AWS_Image_save_load alloc] init];//getImageArray_with_category
        [awssl getImageArray_ranking:
         ^{
             NSArray *imgarr = awssl.S3sdb.Data_Arr;
             //NSArray *sort_imgarr = [awssl rand_sort:imgarr];
             NSMutableArray *title_arr = [[NSMutableArray alloc] init];
             for (NSData *cur_imgtxt_data in imgarr) {
                 //Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
                 Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
                 UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:cur_imgtxt_data];
                 
                 if ([self strcmp_in_arr:imgtxt.news_title in_arr:title_arr]) {
                     continue;
                 }
                 
                 [title_arr addObject:imgtxt.news_title];
                 
                 [tmp_item setNews_imagetext:imgtxt];
                 [_items addObject:tmp_item];
             }
             [m_TblView reloadData];
             [refreshControl endRefreshing];
             [SVProgressHUD dismiss];
             // dispatch_sync(dispatch_get_main_queue(), block);
         }
         ];
        
    });
}


-(BOOL)strcmp_in_arr:(NSString *)str in_arr:(NSArray *)arr
{
    for(NSString *str_in_arr in arr)
    {
        if ([str_in_arr compare:str]==NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

#pragma mark --get cell info from CoreData
-(void) loadInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
         //_items = [[NSMutableArray alloc] initWithArray:tmp_items];
         [_items removeAllObjects];
         Imagetext_save_load *isl = [[Imagetext_save_load alloc] init];
         NSArray *imgtxt_arr = [isl getImageArray];
         for (UIImage_Text *cur_imgtxt in imgtxt_arr) {
             //Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
             Item *tmp_item = [[Item alloc] initWithTable:m_TblView];
             [tmp_item setNews_imagetext:cur_imgtxt];
             
             [_items addObject:tmp_item];
         }
         dispatch_sync(dispatch_get_main_queue(), block);
     });
}

#pragma mark --get cell info from web api
-(void) receiveInfoWithCompletedBlock:(dispatch_block_t)block errorBlock:(dispatch_block_t)errorBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        if([self.news_address compare:@"USER_NEWS"]==NSOrderedSame){
            News_Get_Flag = USER_NEWS;
            [self setNews_Get_Flag:USER_NEWS];
            [self receiveInfo];
            return;
        }
        else if([self.news_address compare:@"NEW_NEWS"]==NSOrderedSame){
            News_Get_Flag = NEW_NEWS;
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.news_address = app.hpaddress;
            //self.title        = app.title;
        }
        else if([self.news_address compare:@"IINE_RANKING"]==NSOrderedSame){
            News_Get_Flag = USER_RANKING;
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            self.news_address = app.hpaddress;
            //self.title        = app.title;
        }
        else {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.hpaddress = self.news_address;
            app.title     = self.title;
        }
        
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
        
        [_items removeAllObjects];
       // Imagetext_save_load *isl = [[Imagetext_save_load alloc] init];

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
            
            NSDictionary *linkHtmlD = [one_chan valueForKey:@"link"];
            NSString *linkHtml = [linkHtmlD valueForKey:@"text"];
            
            // 文字列strの中に@"AAA"というパターンが存在するかどうか
            title = [title stringByReplacingOccurrencesOfString:@"'" withString:@""];
           
            tmp_item.title    = title;
            tmp_item.date     = str_date_jpn;
            tmp_item.category = self.title;
            tmp_item.hpaddress = linkHtml;
            
            
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
    
    if (_items.count!=0) {
        Item *item = _items[indexPath.row];
        [cell setNewsItem:item];
    }
    
    if ((indexPath.row)%2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.0];
        cell.NewsDetail.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1.0];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.NewsDetail.backgroundColor = [UIColor whiteColor];
    }
    
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
    [News_view set_DrawButton_enabled:DrawButton_Flag];
    if(_items.count){
        Item *item = _items[indexPath.row];
        [News_view setCellItem:item];
    }
    
    //News_view.modalTransitionStyle
    [self.navigationController pushViewController:News_view animated:YES];
}

/*
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

*/
@end
