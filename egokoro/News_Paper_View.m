//
//  News_Paper_View.m
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/12.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import "News_Paper_View.h"
#import "SVProgressHUD.h"

@interface News_Paper_View ()
{
    CoreData_save_load *csl_ins;
    int Setimage_from_ACE;
}
@end

static ACEViewController *_paint_view;

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
    csl_ins = [[CoreData_save_load alloc] init];
   // [csl_ins del_allData];
    _News_Text_View.text = self.text;
    
    if(!Setimage_from_ACE){
        if (_paint_view != nil) {
            [self news_draw:_paint_view.drawingView.image];
            return;
        }
    }
    
    if (_paint_view == nil){
        NSData *load_data = [csl_ins get_Data_from_key:self.news_title];
        if(load_data!=nil){
            UIImage_Text *load_image = [NSKeyedUnarchiver unarchiveObjectWithData:load_data];
            [_News_Text_View setDrawImage:load_image.image];
        }
    }

}

-(void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [csl_ins store_NSData:data1 andkey:self.news_title];
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
}

- (IBAction)post_newsImage:(id)sender
{
    UIImage_Text *imagetext = [[UIImage_Text alloc] init];
    imagetext.image = _paint_view.drawingView.image;
    imagetext.text  = self.text;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imagetext];
    [csl_ins store_NSData:data andkey:self.news_title];
}

#pragma mark private mathod
-(void)news_draw:(UIImage *)image
{
    [SVProgressHUD showWithStatus:@"Waiting..."
                         maskType:SVProgressHUDMaskTypeGradient];
    [_News_Text_View delDrawImage];
    [_News_Text_View setDrawImage:image];
    [SVProgressHUD dismiss];
}

@end
