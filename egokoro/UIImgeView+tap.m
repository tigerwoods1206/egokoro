//
//  UIImgeView+tap.m
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/16.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import "UIImgeView+tap.h"

@implementation UIImgeView_tap

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(user_Tap)]) {
        // sampleMethod1を呼び出す
        [self.delegate user_Tap];
    }
    
}

@end
