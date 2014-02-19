//
//  UICustomActionSheet.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/02.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILColorPickerView.h"

@interface UICustomActionSheet : UIViewController<ILColorPickerViewDelegate>
{
    IBOutlet ILColorPickerView *Color_Picker;
}

//@property (weak, nonatomic) IBOutlet ILColorPickerView *Color_Picker;

- (void)presentColorViewController:(UIViewController*)controller animated:(BOOL)animated;
- (void)dismissColorViewController:(UIViewController*)controller animated:(BOOL)animated;

@end
