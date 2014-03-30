//
//  AppDelegate.m
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/07.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HHTabListController.h"
#import "Appirater.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.NEWS_FLAG = USER_NEWS;
    // 次の2行を追加
//    ViewController* topMenu = [[ViewController alloc] init];
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:topMenu];
    
    
    
    NSString *path;
    NSBundle *bundle = [NSBundle mainBundle];
    path = [bundle pathForResource:@"news_category" ofType:@"plist"];
    NSDictionary *plist_dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *newslist = [plist_dict objectForKey:@"news"];
    //NSDictionary *category_list = [newslist objectForKey:@"カテゴリ"];
    NSArray *sortArray = [newslist allKeys];
    
    NSSortDescriptor *sortDescNumber;
    sortDescNumber = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    
    // NSSortDescriptorは配列に入れてNSArrayに渡す
    NSArray *sortDescArray;
    sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
    
    // ソートの実行
    NSArray *news_name_list;
    news_name_list = [sortArray sortedArrayUsingDescriptors:sortDescArray];

    
    NSMutableArray *ep_titles = [[NSMutableArray alloc] init];
    //NSArray *ep_list = @[@"国内",@"国外"];
    //[ep_titles addObject:ep_list];
    
    //NSArray *season_name_list = @[@"news"];
    
    NSMutableDictionary *viewControllers = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *ep_viewControllers = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tmp_epviewcont;
    
    for (NSString *key_news_name in news_name_list ) {
        NSDictionary *one_news = [newslist objectForKey:key_news_name];
        // [one_season]
        NSArray *tmp_ep_list = [one_news allKeys];
        NSArray *ep_list = [tmp_ep_list sortedArrayUsingDescriptors:sortDescArray];
        [ep_titles addObject:ep_list];

        for (NSString *ep_name in ep_list) {
            if ([key_news_name compare:@"モード"]==NSOrderedSame) {
               
            }
            else {
                ViewController* topMenu = [[ViewController alloc] init];
                [topMenu setTitle:ep_name];
                NSString *add = [one_news objectForKey:ep_name];
                topMenu.news_address = add;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:topMenu];
                
                [ep_viewControllers setObject:navigationController forKey:ep_name];
            }
        }
        tmp_epviewcont = [ep_viewControllers copy];
        [viewControllers setObject:tmp_epviewcont forKey:key_news_name];
        [ep_viewControllers removeAllObjects];
    }
    
    
    NSDictionary *data_source = [NSDictionary dictionaryWithObjects:ep_titles forKeys:news_name_list];
    HHTabListController *hhcont;
    hhcont = [HHTabListController alloc];
    hhcont.sectionList = news_name_list;
    hhcont.dataSource = data_source;
    //[hhcont setDelegate:hhcont.delegate];
    hhcont = [hhcont initWithViewControllers:viewControllers backgroundImage:[UIImage imageNamed:@"blue.jpg"]];
    
  	self.viewController = hhcont;
    self.window.rootViewController =  self.viewController;
    
    //    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)appstore_review_init_in_didFinishLaunchingWithOptions
{
    [Appirater setAppId:@""];
    [Appirater appLaunched:YES];
}

- (void)appstore_review_init_in_applicationWillEnterForeground
{
    [Appirater appEnteredForeground:YES];
}

@end
