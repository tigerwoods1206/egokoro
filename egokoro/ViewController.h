//
//  ViewController.h
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/07.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ViewController : UIViewController<UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
#define TABBAR_HEIGHT           (49)
#define NAVIGATIONBAR_HEIGHT    (44)
#define AD_HEIGHT (50)
#define MY_NEWS   0
#define NEW_NEWS  1
#define USER_NEWS 2
    
@public
    enum TAG_TAB { TAG_TAB0, TAG_TAB1, TAG_TAB2, };
    
@private
    CGRect          m_rcMainSrcn;
    CGRect          m_notframSrcn;
    
    UITabBar        *m_TabBar;
    UITabBarItem    *m_Tab0;
    UITabBarItem    *m_Tab1;
    UITabBarItem    *m_Tab2;
    enum TAG_TAB    m_eSelect;
    
    UIView              *m_View;
    UINavigationBar     *m_NavBar;
    UINavigationItem    *m_NavItem;
    UITableView         *m_TblView;
    
    UIToolbar *menuToolBar;
}

@property(retain)  NSMutableArray *items;
@property(retain)  NSString *news_address;

- (void)initView:title withColor:(UIColor *)color;

@end
