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
