//
//  ILColorPickerLayoutBottomExampleController.h
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILColorPickerView.h"

@protocol ILColorPickerLayoutBottomExampleControllerDelegate
- (IBAction)pushOK:(id)sender;
@end

@interface ILColorPickerLayoutBottomExampleController : UIViewController<ILColorPickerViewDelegate> {
    IBOutlet UIView *colorChip;
    IBOutlet ILColorPickerView *colorPicker;
    IBOutlet UIButton *okButton;

}

@property (nonatomic, assign) id<ILColorPickerLayoutBottomExampleControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet ILColorPickerView *colorPicker;

- (IBAction)pushOK:(id)sender;

@end
