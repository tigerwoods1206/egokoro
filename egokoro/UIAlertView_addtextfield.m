//
//  UIAlertView_addtextfield.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/15.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "UIAlertView_addtextfield.h"

@implementation UIAlertView_addtextfield

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)addTextField
{
    // ユーザ名
    UITextField *userNameField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 24)];
    userNameField.placeholder = @"ユーザ名";
    userNameField.font = [UIFont systemFontOfSize:12];
    userNameField.borderStyle = UITextBorderStyleRoundedRect;
    userNameField.backgroundColor = [UIColor clearColor];
    userNameField.tag = 1;
    // キーボードのフォーカスを当てる
    [userNameField becomeFirstResponder];
    // パスワード
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12, 72, 260, 24)];
    passwordField.placeholder = @"パスワード";
    passwordField.font = [UIFont systemFontOfSize:12];
    passwordField.borderStyle = UITextBorderStyleRoundedRect;
    passwordField.backgroundColor =  [UIColor clearColor];
    passwordField.tag = 2;
    passwordField.secureTextEntry = YES;
    [self addSubview:userNameField];
    [self addSubview:passwordField];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
