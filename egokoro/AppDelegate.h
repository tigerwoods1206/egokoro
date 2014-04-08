//
//  AppDelegate.h
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/07.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) NSString *hpaddress;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) int NEWS_FLAG;
@property (assign, nonatomic) NSInteger USERID;

@end
