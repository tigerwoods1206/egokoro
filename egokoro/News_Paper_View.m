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

@interface News_Paper_View ()
{
    Imagetext_save_load *csl_ins;
    AWS_Image_save_load *aws_ins;
    int Setimage_from_ACE;
    ACEViewController *_paint_view;
    NSString *User_Name;
    NSArray *Imgarr;
    int Imgview_Num;
    NSString *news_text;
}
@end

@implementation News_Paper_View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    //self.drawButton_enabled = TRUE;
    csl_ins = [[Imagetext_save_load alloc] init];
    aws_ins = [[AWS_Image_save_load alloc] init];
    Imgarr = nil;
    [_select_Cview setDelegate:self];
    [_select_Cview setDataSource:self];
    [self.select_Cview registerNib:[UINib nibWithNibName:@"MyCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    
}

-(void)viewDidLayoutSubviews
{
  
    self.title = self.news_title;
    [self setButton_enabled:self.drawButton_enabled];
    
    NSArray *imgarr;
    if (self.drawButton_enabled == NO) {
        _select_Cview.hidden = NO;
        //[self init_NewsButton];
        //imgarr = [csl_ins getImage_OneTitle_Array:self.title];
        //Imgview_Num = [imgarr count];
        
        [aws_ins getImageArray_with_title:self.title add_block:
         ^{
             /*
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
              
              });
              */
             NSArray *imgarr = aws_ins.S3sdb.Data_Arr;
             Imgview_Num = [imgarr count];
             [self set_news_image:imgarr];
             Imgarr = imgarr;
             [self.select_Cview reloadData];
             // dispatch_sync(dispatch_get_main_queue(), block);
            
         }
         ];

    }
    else {
        _select_Cview.hidden = YES;
        //[self init_NewsButton];
        [_scrollView setFrame:CGRectMake(0,
                                          _scrollView.frame.origin.y,
                                         _scrollView.frame.size.width,
                                         _scrollView.frame.size.height + _select_Cview.frame.size.height)];
        
        UIImage_Text *imgtxt = [csl_ins getImageText:self.title];
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
   // [self set_newsimage_from_cash];
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
    /*
    UIImage_Text *imagetext = [[UIImage_Text alloc] init];
    imagetext.image = image;
    imagetext.text  = self.text;
    imagetext.news_title = self.news_title;
     */
    //[csl_ins setImageText:imagetext and_key:self.news_title];
    /*
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [csl_ins store_NSData:data1 andkey:self.news_title];
     */
}

-(void)set_newsimage_from_cash
{
    UIImage_Text *cash_image = [csl_ins getImageText:self.news_title];
    if (cash_image!=nil) {
        [self news_draw:cash_image.image];
        [csl_ins delAllImage];
    }
  
}

-(void)user_Tap
{
//    NSLog(@"UserTap");
//    paint_view = [[ACEViewController alloc] init];
//    [self.navigationController pushViewController:paint_view animated:YES];
}

- (IBAction)draw_newsImage:(id)sender {
    _paint_view = [[ACEViewController alloc] init];
    _paint_view.news_view = self;
    //[self.navigationController pushViewController:_paint_view animated:YES];
    [self presentViewController:_paint_view animated:YES completion:nil];
    [News_Image_Text_View delDrawImage];
}

- (IBAction)post_newsImage:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ユーザー名入力"
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:@"キャンセル"
                                           otherButtonTitles:@"投稿する", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
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
            imagetext.user  = User_Name;
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
        cell.cellLabel.text = imgtxt.user;
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //クリックされたらよばれる
    NSLog(@"Clicked %d-%d",indexPath.section,indexPath.row);
    NSData *load_image = [Imgarr objectAtIndex:indexPath.row];
    UIImage_Text *imgtxt = [NSKeyedUnarchiver unarchiveObjectWithData:load_image];
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

@end
