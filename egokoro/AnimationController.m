//
//  AnimationController.m
//  egokoro
//
//  Created by オオタ イサオ on 2013/12/12.
//  Copyright (c) 2013年 オオタ イサオ. All rights reserved.
//

#import "AnimationController.h"

@implementation AnimationController
- (id)init
{
    if (self = [super init])
    {
        // アニメーションの時間
        self.duration = 1.0f;
    }
    
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [self animateTransition:transitionContext fromView:fromVC.view toView:toVC.view];
}

#pragma mark - animation

// アニメーションを作る
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromView:(UIView *)fromView toView:(UIView *)toView
{
    UIView* containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    if (!self.isReverse) [containerView sendSubviewToBack:toView];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    [containerView.layer setSublayerTransform:transform];
    
    UIView *flippedSectionOfView = self.isReverse ? toView : fromView;
    
    if (self.isReverse) flippedSectionOfView.frame = CGRectMake(0, CGRectGetHeight(flippedSectionOfView.frame)*2, flippedSectionOfView.frame.size.height, flippedSectionOfView.frame.size.width);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:1.0
                                                                animations:^{
                                                                    flippedSectionOfView.layer.transform = [self rotate:self.isReverse];
                                                                    
                                                                    if (self.isReverse)
                                                                    {
                                                                        flippedSectionOfView.frame = CGRectMake(0, 0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame));
                                                                    } else
                                                                    {
                                                                        flippedSectionOfView.frame = CGRectMake(0, CGRectGetHeight(flippedSectionOfView.frame)*2, CGRectGetWidth(flippedSectionOfView.frame), CGRectGetHeight(flippedSectionOfView.frame));
                                                                    }
                                                                }];
                              } completion:^(BOOL finished) {
                                  if ([transitionContext transitionWasCancelled])
                                  {
                                      [toView removeFromSuperview];
                                  } else {
                                      [fromView removeFromSuperview];
                                  }
                                  
                                  [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                              }];
}

- (CATransform3D)rotate:(BOOL)initTransform
{
    CATransform3D transform = initTransform ? CATransform3DMakeRotation(0.0, 0.0, 0.0, 0.0) : CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, -2.0);
    
    return  transform;
}
@end
