//
//  News_Paper_View.h
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/12.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageTextView.h"
#import "ACEViewController.h"
#import "ACEDrawingView.h"
#import "Imagetext_save_load.h"
#import "Codable.h"
#import "UIImage+Text.h"
#import "UIAlertView_addtextfield.h"
#import "Item.h"

#define TABBAR_HEIGHT           (49)
#define NAVIGATIONBAR_HEIGHT    (44)
#define AD_HEIGHT (50)

@interface News_Paper_View : UIViewController<UICustumImageTextView_Tap_Delegate,UINavigationBarDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>
{
    UIImageTextView *News_Image_Text_View;
}
@property (weak, nonatomic) IBOutlet UIImageTextView *News_Text_View;
//@property (strong, nonatomic) UIImageTextView *News_Image_Text_View;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *viewnewsButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *Draw_Button;
@property (weak ,nonatomic) IBOutlet UIBarButtonItem *Post_Button;
@property (weak, nonatomic) IBOutlet UICollectionView *select_Cview;

//@property ACEViewController *paint_view;
@property NSString *text;
@property NSString *news_title;
@property NSString *Pub_day;
@property NSString *User;
@property NSString *category;
@property NSString *hpaddress;
//@property(nonatomic ,retain) Save_Props *props;
@property (strong ,nonatomic) Item *CellItem;

@property BOOL      drawButton_enabled;
//@property ACEViewController *paint_view;

-(void)set_text:(NSString *)detail_text;
-(void)set_newstitle:(NSString *)news_title;
-(void)set_newsimage:(UIImage *)image;
-(void)set_newsimage_from_cash;

-(void)set_DrawButton_enabled:(BOOL)enabled;

-(void)user_Tap;
- (IBAction)draw_newsImage:(id)sender;
- (IBAction)post_newsImage:(id)sender;
- (IBAction)changePage:(id)sender;



@end
