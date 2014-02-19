//
//  UICustomActionSheet.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/02.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "UICustomActionSheet.h"

@interface UICustomActionSheet ()

@end

@implementation UICustomActionSheet

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //self.Color_Picker.delegate = self;
    // Do any additional setup after loading the view from its nib.
    //_Color_Picker.pickerLayout=ILColorPickerViewLayoutRight;
    UIColor *c=[UIColor colorWithRed:(arc4random()%100)/100.0f
                               green:(arc4random()%100)/100.0f
                                blue:(arc4random()%100)/100.0f
                               alpha:1.0];
    Color_Picker.color=c;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isExistSubView:(UIView*)view
{
    BOOL is_exist = NO;
    for (UIView* subview in self.view.subviews) {
        if (view == subview) {
            is_exist = YES;
            break;
        }
    }
    return is_exist;
}

- (void)presentColorViewController:(UIViewController*)controller animated:(BOOL)animated
{
    CGRect frame1 = self.view.frame;
    CGRect frame2 = controller.view.frame;
    
    // (1) init position
    frame2.origin.y = frame1.size.height;
    controller.view.frame = frame2;
    
    if ([self isExistSubView:controller.view]) {
        [self.view bringSubviewToFront:controller.view];
    } else {
        [self.view addSubview:controller.view];
    }
    
    // (2) animate
    frame2.origin.y = frame1.size.height - frame2.size.height;
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:^{controller.view.frame = frame2;}];
    } else {
        controller.view.frame = frame2;
    }
    
}
- (void)dismissColorViewController:(UIViewController*)controller animated:(BOOL)animated
{
    if (![self isExistSubView:controller.view]) {
        return;
        // do nothing
    }
    
    CGRect frame1 = self.view.frame;
    CGRect frame2 = controller.view.frame;
    
    // (1) animate
    frame2.origin.y = frame1.size.height;
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:^{controller.view.frame = frame2;}
                         completion:^(BOOL finished){[controller.view removeFromSuperview];}
         ];
    } else {
        [controller.view removeFromSuperview];
    }
}

@end
