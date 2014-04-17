//
//  ILColorPickerLayoutBottomExampleController.m
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILColorPickerLayoutBottomExampleController.h"


@implementation ILColorPickerLayoutBottomExampleController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    if (screenSize.size.height <= 480) {
        // 縦幅が小さい場合には、3.5インチ用のXibファイルを指定します
        //screenType = SCREEN_TYPE_3_5;
        nibNameOrNil = @"ILColorPickerLayoutBottomExampleController_35";
    } else {
        // 立て幅が長い場合には、4.0インチ用のXibファイルを指定します。
        //screenType = SCREEN_TYPE_4_0;
        nibNameOrNil = @"ILColorPickerLayoutBottomExampleController";
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
    
    // Build a random color to show off setting the color on the pickers
    
//    UIColor *c=[UIColor colorWithRed:(arc4random()%100)/100.0f 
//                               green:(arc4random()%100)/100.0f
//                                blue:(arc4random()%100)/100.0f
//                               alpha:1.0];
    
//    colorChip.backgroundColor=c;
//    colorPicker.color=c;
    colorChip.backgroundColor = self.cur_Color;
    colorPicker.color         = self.cur_Color;
}

#pragma mark - ILColorPickerDelegate

-(void)colorPicked:(UIColor *)color forPicker:(ILColorPickerView *)picker
{
    colorChip.backgroundColor=color;
}

- (IBAction)pushOK:(id)sender {
    [self.delegate pushOK:sender];
}
@end
