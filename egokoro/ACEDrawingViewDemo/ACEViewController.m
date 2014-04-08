//
//  ACEViewController.m
//  ACEDrawingViewDemo
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"
#import "ACEDrawingView.h"
#import "UICustomActionSheet.h"
#import "ILColorPickerLayoutBottomExampleController.h"

#import <QuartzCore/QuartzCore.h>

#define kActionSheetColor       100
#define kActionSheetTool        101

@interface ACEViewController ()<
UIActionSheetDelegate,
ACEDrawingViewDelegate,
UINavigationBarDelegate,
ILColorPickerLayoutBottomExampleControllerDelegate
>
{
    BOOL opend;
    UIColor *curColor;
    ILColorPickerLayoutBottomExampleController *colorpick_view;
}

@end

@implementation ACEViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the delegate
    self.drawingView.delegate = self;
    
    // start with a black pen
    self.lineWidthSlider.value = self.drawingView.lineWidth;
    self.lineWidthView.hidden = YES;
    //CGFloat ratio = sender.value/sender.maximumValue;
    CGFloat width = self.lineWidthView.frame.size.width/2;
    self.lineWidthView.layer.cornerRadius = width;
    [self.lineWidthView setFrame:CGRectMake(self.lineWidthView.frame.origin.x,
                                            self.lineWidthView.frame.origin.y,
                                            self.drawingView.lineWidth,
                                            self.drawingView.lineWidth)];

    
    // init the preview image
    self.previewImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.previewImageView.layer.borderWidth = 2.0f;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    opend = FALSE;
    self.end_drawed = FALSE;
    
    curColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void)updateButtonStatus
{
    self.undoButton.enabled = [self.drawingView canUndo];
    self.redoButton.enabled = [self.drawingView canRedo];
}

- (IBAction)takeScreenshot:(id)sender
{
    // show the preview image
   // self.previewImageView.image = self.drawingView.image;
   // self.previewImageView.hidden = NO;
    
    // close it after 3 seconds
    self.previewImageView.hidden = YES;
    self.end_drawed = TRUE;
   // [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_news_view set_newsimage:self.drawingView.image];
    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
//        self.previewImageView.hidden = YES;
//        [self.navigationController popViewControllerAnimated:YES];
//    });
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)undo:(id)sender
{
    [self.drawingView undoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)redo:(id)sender
{
    [self.drawingView redoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)clear:(id)sender
{
    [self.drawingView clear];
    [self updateButtonStatus];
}


#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}


#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        if (actionSheet.tag == kActionSheetColor) {
            
            self.colorButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.lineColor = [UIColor blackColor];
                    break;
                    
                case 1:
                    self.drawingView.lineColor = [UIColor redColor];
                    break;
                    
                case 2:
                    self.drawingView.lineColor = [UIColor greenColor];
                    break;
                    
                case 3:
                    self.drawingView.lineColor = [UIColor blueColor];
                    break;
            }
            
        } else {
            
            self.toolButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.drawTool = ACEDrawingToolTypePen;
                    break;
                    
                case 1:
                    self.drawingView.drawTool = ACEDrawingToolTypeLine;
                    break;
                    
                case 2:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleStroke;
                    break;
                    
                case 3:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleFill;
                    break;
                    
                case 4:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseStroke;
                    break;
                    
                case 5:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseFill;
                    break;
                    
                case 6:
                    self.drawingView.drawTool = ACEDrawingToolTypeEraser;
                    break;
            }
        
            // if eraser, disable color and alpha selection
            self.colorButton.enabled = self.alphaButton.enabled = buttonIndex != 6;
        }
    }
}

#pragma mark - Settings

- (IBAction)colorChange:(id)sender
{
    colorpick_view = [[ILColorPickerLayoutBottomExampleController alloc] init];
    colorpick_view.delegate = self;
    colorpick_view.cur_Color = curColor;
    
    [self presentViewController:colorpick_view animated:YES completion:nil];
}

-(void)pushOK:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil ];
    self.drawingView.lineColor =  colorpick_view.colorPicker.color;
    curColor = colorpick_view.colorPicker.color;
    
}

- (IBAction)toolChange:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Selet a tool"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"ペン", @"直線",
                                  @"四角 (Stroke)", @"四角 (Fill)",
                                  @"楕円 (Stroke)", @"楕円 (Fill)",
                                  @"消しゴム",
                                  nil];
    
    [actionSheet setTag:kActionSheetTool];
    [actionSheet showInView:self.view];
}

- (IBAction)toggleWidthSlider:(id)sender
{
    // toggle the slider
    self.lineWidthSlider.hidden = !self.lineWidthSlider.hidden;
    self.lineWidthView.hidden = self.lineWidthSlider.hidden;
    self.lineAlphaSlider.hidden = YES;
}


- (IBAction)widthChange:(UISlider *)sender
{
    self.drawingView.lineWidth = sender.value;
    CGFloat width = self.lineWidthView.frame.size.width/2;
    self.lineWidthView.layer.cornerRadius = width;
   // CGFloat ratio = sender.value/sender.maximumValue;
    [self.lineWidthView setFrame:CGRectMake(self.lineWidthView.frame.origin.x,
                                            self.lineWidthView.frame.origin.y,
                                            self.drawingView.lineWidth,
                                            self.drawingView.lineWidth)];
    //self.lineWidthView.layer.cornerRadius = width * sender.value/sender.maximumValue;
    self.lineWidthView.clipsToBounds=YES;
    self.lineWidthView.backgroundColor = curColor;
}

- (IBAction)toggleAlphaSlider:(id)sender
{
    // toggle the slider
    self.lineAlphaSlider.hidden = !self.lineAlphaSlider.hidden;
    self.lineWidthSlider.hidden = YES;
    self.lineWidthView.hidden = self.lineAlphaSlider.hidden;
}

- (IBAction)alphaChange:(UISlider *)sender
{
    self.drawingView.lineAlpha = sender.value;
    self.lineWidthView.alpha = sender.value;
    self.lineWidthView.backgroundColor = curColor;
}

@end
