//
//  UIImageTextView.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/01/03.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "UIImageTextView.h"

@implementation UIImageTextView

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

-(void)setDrawImage:(UIImage *)image
{
    
    // 非表示領域を設定（四角形）
    CGRect exclusionRect =
    CGRectMake(320 - image.size.width*0.5, 20,
               image.size.width*0.5, image.size.height*0.5);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:exclusionRect];
    
    // テキストビューに設定
    self.textContainer.exclusionPaths = @[path];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = exclusionRect;
    self.imgview = imageView;
    [self addSubview:imageView];
}

-(void)delDrawImage
{
    for (UIImageView *subview in [self subviews]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
}

-(void)cutOutframeText
{
    CGSize textview_size = [self.text sizeWithFont:self.font
                               constrainedToSize:self.frame.size];
    NSUInteger max_numberOfLines = 0;
    if (textview_size.height <= self.frame.size.height) {
        max_numberOfLines = self.frame.size.height / self.font.lineHeight;
    }
    NSUInteger numberOfLines = 0;
    NSUInteger max_chars_num = 0;
    for (NSUInteger i = 0; i < self.text.length; i++) {
        if ([[NSCharacterSet newlineCharacterSet]
             characterIsMember: [self.text characterAtIndex: i]]) {
            numberOfLines++;
            if (numberOfLines > max_numberOfLines) {
                max_chars_num = i;
                break;
            }
        }
    }
    
    [self setTextLengthLimit:max_chars_num];
}

-(void)setTextLengthLimit:(NSInteger)length
{
    if (self.text.length <= length) {
        return;
    }
    NSString *old_text = self.text;
    NSString *new_text = [old_text substringToIndex:length];
    self.text = new_text;
}

@end
