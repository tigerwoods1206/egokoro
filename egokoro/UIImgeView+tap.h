//
//  UIImgeView+tap.h
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/16.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>

// デリゲートを定義
@protocol UIImageView_Tap_Delegate <NSObject>

// デリゲートメソッドを宣言
// （宣言だけしておいて，実装はデリゲート先でしてもらう）
- (void)user_Tap;

@end

@interface UIImgeView_tap : UIImageView

@property (nonatomic, assign) id<UIImageView_Tap_Delegate> delegate;

@end
