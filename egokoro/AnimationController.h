//
//  AnimationController.h
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/12.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationController : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isReverse;
@property (nonatomic, assign) NSTimeInterval duration;

@end
