//
//  UIImageTextView.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/03.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICustumImageTextView_Tap_Delegate <UITextViewDelegate>

// デリゲートメソッドを宣言
// （宣言だけしておいて，実装はデリゲート先でしてもらう）
- (void)user_Tap;

@end

@interface UIImageTextView : UITextView

@property(nonatomic,assign) id<UICustumImageTextView_Tap_Delegate> delegate;
@property(nonatomic,retain) UIImageView *imgview;

-(void)setDrawImage:(UIImage *)image;
-(void)delDrawImage;
-(void)cutOutframeText;

@end
