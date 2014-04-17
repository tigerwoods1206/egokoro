//
//  News_Paper_View.m
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/12.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import "News_Paper_View.h"
#import "SVProgressHUD.h"
#import "AWS_Image_save_load.h"
#import "MyCell.h"
#import "GetAPPGrobal.h"
#import "Post_Check.h"


@interface News_Paper_View ()
{
    Imagetext_save_load *csl_ins;
    AWS_Image_save_load *aws_ins;
    int Setimage_from_ACE;
    ACEViewController *_paint_view;
    NSString *User_Name;
    NSArray *Imgarr, *Adbarr;
    int Imgview_Num;
    NSString *news_text;
    BOOL Ranking_Flag;
}
@end

@implementation News_Paper_View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    if (screenSize.size.height <= 480) {
        // 縦幅が小さい場合には、3.5インチ用のXibファイルを指定します
        //screenType = SCREEN_TYPE_3_5;
        nibNameOrNil = @"News_Paper_View_35";
    } else {
        // 立て幅が長い場合には、4.0インチ用のXibファイルを指定します。
        //screenType = SCREEN_TYPE_4_0;
        nibNameOrNil = @"News_Paper_View";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
         //_paint_view = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    Setimage_from_ACE = FALSE;
    Ranking_Flag = FALSE;
    //self.drawButton_enabled = TRUE;
    csl_ins = [[Imagetext_save_load alloc] init];
    aws_ins = [[AWS_Image_save_load alloc] init];
    Imgarr = nil;
    [_select_Cview setDelegate:self];
    [_select_Cview setDataSource:self];
    [self.select_Cview registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    
    //ad
    _bannerView = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            self.view.frame.size.height - GAD_SIZE_320x50.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    
    // ここで、AdMobパブリッシャーID ではなく AdMobメディエーションID を設定する
    _bannerView.adUnitID = MY_BANNER_UNIT_ID_2;
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する。
    _bannerView.rootViewController = self;
    _bannerView.delegate = self;
    
    [self.view addSubview:_bannerView];
    
    // 一般的なリクエストを行って広告を読み込む。
    [_bannerView loadRequest:[GADRequest request]];

    UISwipeGestureRecognizer *swipeUpgesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(processSwipeLeft:)];
    swipeUpgesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.scrollView addGestureRecognizer:swipeUpgesture];
    
}

-(void)viewDidLayoutSubviews
{
  
    self.title = self.news_title;
   
    [self setButton_enabled:self.drawButton_enabled];
    [self Update_IineLabel];
    
    if (Ranking_Flag) {
        [self load_image_with_user];
    }
    else if (self.drawButton_enabled == NO) {
        [self load_image_widh_titles];
    }
    else {
        [self load_image_with_cash];
        [self draw_newsImage_core];
        //
    }
}

#pragma  -mark private
-(void)load_image_widh_titles
{
    _select_Cview.hidden = NO;
    [aws_ins getImageArray_with_title:self.title add_block:
     ^{
         NSArray *imgarr = aws_ins.S3sdb.Data_Arr;
         Imgview_Num = [imgarr count];
         [self set_news_image:imgarr];
         Imgarr = imgarr;
         Adbarr = aws_ins.S3sdb.Adb_Arr;
         [self.select_Cview reloadData];
         // dispatch_sync(dispatch_get_main_queue(), block);
         
     }
     ];
}

-(void)load_image_with_user
{
    _select_Cview.hidden = YES;
    //[self init_NewsButton];
    [_scrollView setFrame:CGRectMake(0,
                                     _scrollView.frame.origin.y,
                                     _scrollView.frame.size.width,
                                     _scrollView.frame.size.height + _select_Cview.frame.size.height)];
    
    [aws_ins getImageArray_with_title:self.title add_block:
     ^{
         NSArray *imgarr = aws_ins.S3sdb.Data_Arr;
         Imgview_Num = [imgarr count];
         [self set_news_image:imgarr];
         Imgarr = imgarr;
         Adbarr = aws_ins.S3sdb.Adb_Arr;
         [self.select_Cview reloadData];
         // dispatch_sync(dispatch_get_main_queue(), block);
         
     }
     ];
}


-(void)load_image_with_cash
{
     NSArray *imgarr;
    _select_Cview.hidden = YES;
    //[self init_NewsButton];
    [_scrollView setFrame:CGRectMake(0,
                                     _scrollView.frame.origin.y,
                                     _scrollView.frame.size.width,
                                     _scrollView.frame.size.height + _select_Cview.frame.size.height)];
    
    NSString *cash_key = [NSString stringWithFormat:@"%@_%@_@cash",self.news_title, self.User];
    UIImage_Text *imgtxt = [csl_ins getImageText:cash_key];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imgtxt];
    if (imgtxt == nil) {
        imgarr = nil;
        Imgview_Num = 1;
    }
    else {
        imgarr = [[NSArray alloc ] initWithObjects:data, nil];
        Imgview_Num = [imgarr count];
    }
    Imgarr = imgarr;
    //[self.select_Cview reloadData];
    [self set_news_image:imgarr];
}


-(void)set_news_image:(NSArray *)imgarr
{
    [self scrollview_init];
    
   // for(int i = 0;i<Imgview_Num;i++){
    for(int i = 0;i<1;i++){
        News_Image_Text_View      = [[UIImageTextView alloc] initWithFrame:_scrollView.frame];
        CGPoint center = CGPointMake(_scrollView.center.x + i * _scrollView.frame.size.width,
                                     _scrollView.center.y);
        [News_Image_Text_View setCenter:center];
        // News_Image_Text_View.frame.origin.x = i * _scrollView.frame.size.width;
        News_Image_Text_View.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
        News_Image_Text_View.text = self.text;
        News_Image_Text_View.editable = NO;
        [_scrollView addSubview:News_Image_Text_View];
        UILabel *swipe =  [[UILabel alloc] initWithFrame:_Swipe_Label.frame];
        [swipe setText:@"Swipe Left to お絵描き"];
        [swipe setFont:_Swipe_Label.font];
        swipe.textColor = _Swipe_Label.textColor;
        [_scrollView addSubview:swipe];
       // [_Swipe_Label bringSubviewToFront:self.view];
        
        if(!Setimage_from_ACE){
            if (_paint_view != nil && _paint_view.end_drawed) {
                [self news_draw:_paint_view.drawingView.image];
            }
        }
        
        if (imgarr != nil) {
            NSData *load_image = [imgarr objectAtIndex:i];
            UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:load_image];
            [self news_draw:imgtxt.image];
        }
    }

}

- (void)scrollview_init
{
    self.scrollView.pagingEnabled = YES;
    //self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * Imgview_Num, _scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = YES;
    self.scrollView.delegate = self;
    self.pageControl.numberOfPages = Imgview_Num;
    self.pageControl.currentPage = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    //[self set_newsimage_from_cash];
}

#pragma -mark private
-(void)setButton_enabled:(BOOL)enabled
{
    self.Draw_Button.enabled = self.drawButton_enabled;
    self.Post_Button.enabled = self.drawButton_enabled;
}

-(void)init_NewsButton
{
    if (_select_Cview.hidden == YES) {
         [_viewnewsButton bringSubviewToFront:self.scrollView];
        [_viewnewsButton setFrame:CGRectMake(_viewnewsButton.frame.origin.x,
                                             _select_Cview.frame.origin.y,
                                             _viewnewsButton.frame.size.width,
                                             _viewnewsButton.frame.size.height)];
    }
    else {
        [_viewnewsButton bringSubviewToFront:self.scrollView];
        [_viewnewsButton setFrame:CGRectMake(_viewnewsButton.frame.origin.x,
                                             _select_Cview.frame.origin.y -
                                             _viewnewsButton.frame.size.height,
                                             _viewnewsButton.frame.size.width,
                                             _viewnewsButton.frame.size.height)];
    }
}

-(void)set_DrawButton_enabled:(BOOL)enabled
{
    self.drawButton_enabled = enabled;
}


-(void)viewDidAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
   // [_News_Text_View delDrawImage];
   
 //        [News_Image_Text_View delDrawImage];
   
   
    [self set_DrawButton_enabled:TRUE];
    Setimage_from_ACE = FALSE;
    _paint_view = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCellItem:(Item *)CellItem
{
    self.User = CellItem.user;
    self.news_title = CellItem.title;
    self.text = CellItem.description;
    self.hpaddress = CellItem.hpaddress;
    self.Pub_day = CellItem.date;
    self.category = CellItem.category;
    
    news_text = [NSString stringWithString:self.text];
    
   // self.text = [NSString stringWithFormat:@"%@\n%@",self.text,self.hpaddress];
    // self.props   = CellItem.props;
}

-(void)set_text:(NSString *)detail_text
{
    self.text = detail_text;
}

-(void)set_newstitle:(NSString *)news_title
{
    self.news_title = news_title;
}

-(void)set_newsimage:(UIImage *)image
{
    Setimage_from_ACE = TRUE;
    [self news_draw:image];
    
    UIImage_Text *imagetext = [[UIImage_Text alloc] init];
    imagetext.image = image;
    imagetext.text  = self.text;
    imagetext.news_title = self.news_title;
    
    NSString *cash_key = [self get_coredata_cashname];
    [csl_ins setImageText:imagetext and_key:cash_key];
    /*
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [csl_ins store_NSData:data1 andkey:self.news_title];
     */
}

-(void)set_newsimage_from_cash
{
     NSString *cash_key = [self get_coredata_cashname];
   // [csl_ins setImageText:imagetext and_key:cash_key];

    UIImage_Text *cash_image = [csl_ins getImageText:cash_key];
    if (cash_image!=nil) {
        [self news_draw:cash_image.image];
       // [csl_ins del_Data_from_key:cash_key];
    }
  
}

-(NSString *)get_coredata_cashname
{
    NSString *cash_key = [NSString stringWithFormat:@"%@_%@_@cash",self.news_title, self.User];
    return cash_key;
}

-(void)user_Tap
{
//    NSLog(@"UserTap");
//    paint_view = [[ACEViewController alloc] init];
//    [self.navigationController pushViewController:paint_view animated:YES];
}

#pragma  -mark action
- (IBAction)draw_newsImage:(id)sender {
    [self draw_newsImage_core];
}
-(void)draw_newsImage_core
{
    _paint_view = [[ACEViewController alloc] init];
    _paint_view.news_view = self;
    //[self.navigationController pushViewController:_paint_view animated:YES];
   // _paint_view.modalTransitionStyle = UIModalPresentationPageSheet;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    _paint_view.modalTransitionStyle = UIModalPresentationNone;
    [self presentViewController:_paint_view animated:YES completion:nil];
    [News_Image_Text_View delDrawImage];
}

- (IBAction)post_newsImage:(id)sender
{
    if ([Post_Check chk_enable_post]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ユーザー名入力"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                              otherButtonTitles:@"投稿する", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];

    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"投稿は一日10回までです。"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];

    }
}

-(void)processSwipeLeft:(UITapGestureRecognizer *)sender
{
    if (self.drawButton_enabled == NO) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self draw_newsImage_core];
    }

}

#pragma mark -alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        User_Name = [[alertView textFieldAtIndex:0] text];
        UIImage_Text *imagetext = [[UIImage_Text alloc] init];
        //if (_News_Text_View.imgview.image!=nil) {
        if(News_Image_Text_View.imgview.image!=nil){
            imagetext.image = News_Image_Text_View.imgview.image;
            imagetext.text  = news_text;
            imagetext.news_title  = self.news_title;
            imagetext.pub_day = self.Pub_day;
            NSString *User_Name_Add = [NSString stringWithFormat:@"%@#%@",User_Name,
                                       [Const makeUniqueString]];
            imagetext.user  = User_Name_Add;
            User_Name = User_Name_Add;
            imagetext.category = self.category;
            imagetext.hpadress = self.hpaddress;
            [aws_ins setImageText:imagetext];
        }

    }
}

#pragma mark private mathod
-(void)news_draw:(UIImage *)image
{
    [SVProgressHUD showWithStatus:@"Waiting..."
                         maskType:SVProgressHUDMaskTypeGradient];
    [News_Image_Text_View delDrawImage];
    [News_Image_Text_View setDrawImage:image];
    [self Update_IineLabel];
    [SVProgressHUD dismiss];
}

- (IBAction)changePage:(id)sender {
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
}

#pragma mark scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = _scrollView.frame.size.width;
    _pageControl.currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
   // [_name_scrollView setsc
}

#pragma mark collection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //とりあえずセクションは2つ
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section==0){//セクション0には５個
        return [Imgarr count];
    }else{
        return 0;
    }
}



//Method to create cell at index path
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MyCell *cell;
    
    if(indexPath.section==0){//セクション0のセル
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
        NSData *load_image = [Imgarr objectAtIndex:indexPath.row];
        UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:load_image];
        [cell.imgview setImage:imgtxt.image];
        //int length = [Const makeUniqueString];
        NSRange searchResult = [imgtxt.user rangeOfString:@"#"];
        NSString *User_short;
        if(searchResult.location == NSNotFound){
            // みつからない場合の処理
            User_short = imgtxt.user;
        }else{
            // みつかった場合の処理
            User_short = [imgtxt.user substringToIndex:searchResult.location];
        }
      
        cell.cellLabel.text = User_short;
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //クリックされたらよばれる
    NSLog(@"Clicked %d-%d",indexPath.section,indexPath.row);
    NSData *load_image = [Imgarr objectAtIndex:indexPath.row];
    UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:load_image];
    self.User = imgtxt.user;
    [self news_draw:imgtxt.image];
}

#pragma  -mark text delegate
- (IBAction)WebopenURL:(id)sender
{
    UIViewController *uivc = [[UIViewController alloc] init];
    UIWebView *uiweb = [[UIWebView alloc] initWithFrame:self.view.frame];
    [uiweb loadRequest:
     [NSURLRequest requestWithURL:
      [NSURL URLWithString:self.hpaddress ]]];
    //_web_page.scalesPageToFit = YES;
    uiweb.dataDetectorTypes = UIDataDetectorTypeNone;
 
    uivc.view = uiweb;
    [self.navigationController pushViewController:uivc animated:YES];
    
  //  return NO;
}
#pragma -mark action

- (IBAction)delImage:(id)sender;
{
    NSString *cash_key = [self get_coredata_cashname];
    UIImage_Text *imgtxt = [csl_ins getImageText:cash_key];
    if (imgtxt!=nil) {
        if(imgtxt.user==nil) imgtxt.user = self.User;
        if(imgtxt.news_title ==nil) imgtxt.news_title = self.news_title;
        [aws_ins delImageText:imgtxt];
        [csl_ins del_Data_from_key:cash_key];
    }
}

#pragma -mark Iine button
- (IBAction)Vote_Iine:(id)sender
{
    NSString *key;
    AnyData_forSimpleDB *one_adb;
    IINE_method *iine = [[IINE_method alloc] init];
    for (AnyData_forSimpleDB *adb in Adbarr) {
        NSString *username = [adb get_value:@"user"];
        if ([[adb get_value:@"user"] compare:self.User] == NSOrderedSame) {
            key = adb.s3Data;
            one_adb = adb;
            break;
        }
    }
    
    BOOL ret = [iine Vote_IINE:one_adb];
    if(ret){
        [self Update_IineLabel];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"いいね。は一日一回だけです。"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
    
}

- (IBAction)delallVote:(id)sender
{
    IINE_method *iine = [[IINE_method alloc] init];
    [iine delete_Vote_All];
}

-(void)Update_IineLabel
{
    if (self.drawButton_enabled) {
        self.Iine_Button.enabled = NO;
        self.IineNum.enabled = NO;
        self.IineNum.hidden = YES;
        return;
    }
    else {
        self.Iine_Button.enabled = YES;
        self.IineNum.enabled = YES;
         self.IineNum.hidden = NO;
    }
    IINE_method *iine = [[IINE_method alloc] init];
    NSArray *onearr = [iine Get_IINE:self.User and_news_title:self.news_title];
    if ([onearr count]==0) {
        self.IineNum.text = [NSString stringWithFormat:@"0"];
        return;
    }
    AnyData_forSimpleDB *adb = [onearr objectAtIndex:0];
    self.IineNum.text = [adb get_value:@"hpadress"];
}

@end
