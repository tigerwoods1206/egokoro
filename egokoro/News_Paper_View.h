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
#import "CoreData_save_load.h"
#import "Codable.h"
#import "UIImage+Text.h"

#define TABBAR_HEIGHT           (49)
#define NAVIGATIONBAR_HEIGHT    (44)
#define AD_HEIGHT (50)

@interface News_Paper_View : UIViewController<UICustumImageTextView_Tap_Delegate,UINavigationBarDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIImageTextView *News_Text_View;
//@property ACEViewController *paint_view;
@property NSString *text;
@property NSString *news_title;
@property NSString *Pub_day;
//@property ACEViewController *paint_view;

-(void)set_text:(NSString *)detail_text;
-(void)set_newstitle:(NSString *)news_title;
-(void)set_newsimage:(UIImage *)image;

-(void)user_Tap;
- (IBAction)draw_newsImage:(id)sender;
- (IBAction)post_newsImage:(id)sender;

@end
