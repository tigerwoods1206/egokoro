/*
 * Copyright (c) 2012-2013, Pierre Bernard & Houdah Software s.à r.l.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "HHTabListController.h"

#import "HHTabList.h"

#import <QuartzCore/QuartzCore.h>

#import "HHTabListContainerView.h"
#import "HHTabListTabsView.h"
#import "HHTabListCell.h"

#import <objc/runtime.h>


#if HH_STATUS_BAR_TINT_HACK_ENABLED
static NSString * const kBackgroundNavigationControllerKey = @"backgroundNavigationController";
#endif


@interface HHTabListView : UIView
@end


@interface HHTabListWorkaroundViewController : UIViewController
@end


@interface HHTabListController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
	struct {
		BOOL shouldSelectViewController:1;
		BOOL willSelectViewController:1;
		BOOL didSelectViewController:1;
	} _delegateFlags;
}

@property (nonatomic, copy) NSDictionary *viewControllers;
@property (nonatomic, copy) UIImage *backgroundImage;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) NSUInteger selectedSection;
@property (nonatomic, getter = isTabListRevealed, assign) BOOL tabListRevealed;
@property (nonatomic, assign) BOOL wasTabListRevealed;
@property (nonatomic, assign) CGFloat panOriginX;
@property (nonatomic, assign) BOOL animationInProgress;

#if HH_ARC_ENABLED
@property (nonatomic, strong) NSMutableSet *gestureRecognizers;
@property (nonatomic, strong) HHTabListTabsView *tabListTabsView;
@property (nonatomic, strong) UIViewController *lastSelectedViewController;
@property (nonatomic, strong) HHTabListContainerView *containerView;
#else
@property (nonatomic, retain) NSMutableSet *gestureRecognizers;
@property (nonatomic, retain) HHTabListTabsView *tabListTabsView;
@property (nonatomic, retain) UIViewController *lastSelectedViewController;
@property (nonatomic, retain) HHTabListContainerView *containerView;
#endif

- (void)setSelectedIndex:(NSUInteger)selectedIndex  setSelectedSection:(NSInteger)selectedSection animated:(BOOL)animated;
- (void)setTabListRevealed:(BOOL)tabListRevealed animated:(BOOL)animated;

- (void)removeGestureRecognizers;

@end


static NSString * const kTitleKey = @"title";
static NSString * const kFrameKey = @"frame";

static UIInterfaceOrientation HHInterfaceOrientation(void);
static CGRect HHCGRectRotate(CGRect rect);
static CGRect HHScreenBounds(void);
static CGFloat HHStatusBarHeight(void);


@implementation HHTabListController

#pragma mark -
#pragma mark Initialization

#if HH_STATUS_BAR_TINT_HACK_ENABLED

static BOOL OSVersion6OrAbove = NO;

+ (void)initialize
{
    if (self == [HHTabListController class]) {
        if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 6)  {
            OSVersion6OrAbove = YES;
        }
    }
}

#endif

- (id)initWithViewControllers:(NSDictionary*)viewControllers
{
    return [self initWithViewControllers:viewControllers backgroundImage:nil];
}

- (id)initWithViewControllers:(NSDictionary*)viewControllers backgroundImage:(UIImage *)backgroundImage
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
		_selectedIndex = NSNotFound;
        _selectedSection = NSNotFound;
		_tabListRevealed = NO;
		_wasTabListRevealed = !_tabListRevealed;
        _containerMayPan = YES;
		_gestureRecognizers = [[NSMutableSet alloc] initWithCapacity:5];
		_backgroundImage = backgroundImage;
      
        self.viewControllers = viewControllers;

		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            //self.contentSizeForViewInPopover = CGSizeMake(320.0f, 1004.0f);
            self.preferredContentSize = CGSizeMake(320.0f, 1004.0f);
		}
		else {
			//self.wantsFullScreenLayout = YES;
            self.preferredContentSize = CGSizeMake(320.0f, 2004.0f);
		}

		[self view]; // Force view to load
    }

	return self;
}

- (void)loadView
{
	CGRect frame = CGRectZero;
	CGRect applicationFrame = HHScreenBounds();
	CGFloat statusBarHeight = HHStatusBarHeight();

	applicationFrame.size.height -= statusBarHeight;

	if (self.wantsFullScreenLayout) {
		applicationFrame.origin.y += statusBarHeight;
	}

    
	frame = applicationFrame;

    HHTabListView *layoutContainerView = [[HHTabListView alloc] initWithFrame:frame];
	
	layoutContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    layoutContainerView.autoresizesSubviews = YES;
    layoutContainerView.clipsToBounds = YES;

	layoutContainerView.backgroundColor = [UIColor viewFlipsideBackgroundColor];

	self.view = HH_AUTORELEASE(layoutContainerView);

	CGRect tableFrame = frame;
	HHTabListTabsView *tabListTabsView = [[HHTabListTabsView alloc] initWithFrame:tableFrame
																  backgroundImage:self.backgroundImage];

	tabListTabsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	tabListTabsView.dataSource = self;
	tabListTabsView.delegate = self;

	self.tabListTabsView = HH_AUTORELEASE(tabListTabsView);
    self.tabListTabsView.scrollEnabled = YES;

    [layoutContainerView addSubview:self.tabListTabsView];

	[self setTabListRevealed:self.tabListRevealed animated:NO];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidChangeStatusBarFrameNotification:)
												 name:UIApplicationDidChangeStatusBarFrameNotification
											   object:nil];

	[self.view addObserver:self forKeyPath:@"frame" options:0 context:(__bridge void *)kFrameKey];
}

- (void)viewDidLayoutSubviews
{
	UIView *view = self.view;
	HHTabListTabsView *tabListTabsView = self.tabListTabsView;
	CGRect bounds = [view bounds];

	//if (self.wantsFullScreenLayout) {
		CGFloat statusBarHeight = HHStatusBarHeight();

		bounds.origin.y += statusBarHeight;
	//}

	[tabListTabsView setFrame:bounds];
}


#pragma mark -
#pragma mark Finalization

- (void)dealloc
{
    for (NSString *section_name in _sectionList) {
        NSArray *eps =  [_dataSource objectForKey:section_name];
        NSDictionary *eps_view = [_viewControllers objectForKey:section_name];
        for (NSString *ep_name in eps) {
            UIViewController *viewController = [eps_view objectForKey:ep_name];
            [viewController removeObserver:self forKeyPath:@"title" context:(__bridge void*)kTitleKey];
        }
    }

	if ([self isViewLoaded]) {
		[self.view removeObserver:self forKeyPath:@"frame" context:(__bridge void *)kFrameKey];
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [self removeGestureRecognizers];

	HH_CLEAN(_delegate);

	HH_RELEASE(_viewControllers);
	HH_RELEASE(_lastSelectedViewController);
	HH_RELEASE(_gestureRecognizers);
	HH_RELEASE(_tabListTabsView);
	HH_RELEASE(_containerView);
	HH_RELEASE(_backgroundImage);

#if !HH_ARC_ENABLED
    [super dealloc];
#endif
}

#pragma mark -
#pragma mark Accessors

@synthesize viewControllers = _viewControllers;
@synthesize lastSelectedViewController = _lastSelectedViewController;
@synthesize containerView = _containerView;
@synthesize delegate = _delegate;
@synthesize selectedIndex = _selectedIndex;
@synthesize selectedSection = _selectedSection;
@synthesize tabListRevealed = _tabListRevealed;
@synthesize containerMayPan = _containerMayPan;
@synthesize wasTabListRevealed = _wasTabListRevealed;
@synthesize panOriginX = _panOriginX;
@synthesize animationInProgress = _animationInProgress;
@synthesize gestureRecognizers = _gestureRecognizers;
@synthesize tabListTabsView = _tabListTabsView;
@synthesize backgroundImage = _backgroundImage;

- (void)setDelegate:(id<HHTabListControllerDelegate>)delegate
{
	_delegate = delegate;

	_delegateFlags.shouldSelectViewController = [delegate respondsToSelector:@selector(tabListController:shouldSelectViewController:)];
	_delegateFlags.willSelectViewController = [delegate respondsToSelector:@selector(tabListController:willSelectViewController:)];
	_delegateFlags.didSelectViewController = [delegate respondsToSelector:@selector(tabListController:didSelectViewController:)];
}

- (void)setViewControllers:(NSDictionary *)viewControllers
{
    for (NSString *section_name in _sectionList) {
        NSArray *eps =  [_dataSource objectForKey:section_name];
        NSDictionary *eps_view = [viewControllers objectForKey:section_name];
        for (NSString *ep_name in eps) {
            UIViewController *viewController = [eps_view objectForKey:ep_name];
            //[viewControllers ]
            if (viewController == nil) {
                NSLog(@"viewcont = %@", viewControllers);
            }
            else {
                @try {
                    [viewController removeObserver:self forKeyPath:@"title" context:(__bridge void*)kTitleKey];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error %@", exception);
                }
            }
        }
    }
    
	UIViewController *oldSelectedViewController = self.selectedViewController;
	NSDictionary *newViewControllers = [viewControllers copy];
    
	//NSUInteger newIndex = [newViewControllers indexOfObject:oldSelectedViewController];
   // NSUInteger newIndex = [newViewControllers in
    NSUInteger newIndex, newSection;
    newIndex = NSNotFound;
    newSection = NSNotFound;
//    for (NSString *section_name in _sectionList) {
//        NSDictionary *newviewconts =  [newViewControllers objectForKey:section_name];
//        newSection = [_sectionList indexOfObject:section_name];
//        newIndex = [newviewconts indexOfObject:oldSelectedViewController];
//        if (newIndex != NSNotFound) {
//            break;
//        }
//    }
    for (NSString *section_name in _sectionList) {
        NSArray *eps =  [_dataSource objectForKey:section_name];
        NSDictionary *eps_view = [viewControllers objectForKey:section_name];
        for (NSString *ep_name in eps) {
            UIViewController *viewController = [eps_view objectForKey:ep_name];
            
            if (viewController == oldSelectedViewController) {
                newSection = [_sectionList indexOfObject:section_name];
                newIndex = [eps indexOfObject:ep_name];
            }
        }
    }
	NSUInteger newSelectedIndex = 0;
    NSUInteger newSelectedSection = 0;

	if (newIndex != NSNotFound && newSection != NSNotFound) {
		newSelectedIndex   = newIndex;
        newSelectedSection = newSection;
	}
	else if (newIndex < [_viewControllers count]) {
		newSelectedIndex = newIndex;
        newSelectedSection = newSection;
	}

	[self willChangeValueForKey:@"viewControllers"];

	_viewControllers = newViewControllers;

	[self didChangeValueForKey:@"viewControllers"];

    for (NSString *section_name in _sectionList) {
        NSArray *eps =  [_dataSource objectForKey:section_name];
        NSDictionary *eps_view = [viewControllers objectForKey:section_name];
        for (NSString *ep_name in eps) {
            UIViewController *viewController = [eps_view objectForKey:ep_name];
            [viewController addObserver:self forKeyPath:@"title" options:0 context:(__bridge void*)kTitleKey];
        }
    }
    
//	for (UIViewController *viewController in _viewControllers) {
//		[viewController addObserver:self forKeyPath:@"title" options:0 context:(__bridge void*)kTitleKey];
//	}

	self.selectedIndex = newSelectedIndex;
    self.selectedSection = newSelectedSection;

	HHTabListTabsView *tabListTabsView = self.tabListTabsView;

    if (tabListTabsView != nil) {
        
        [tabListTabsView reloadData];
        [tabListTabsView selectRowAtIndexPath:[NSIndexPath indexPathForRow:newSelectedIndex inSection:newSelectedSection]
                                     animated:NO
                               scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void*)kTitleKey) {
		HHTabListTabsView *tabListTabsView = self.tabListTabsView;
		NSUInteger selectedIndex = self.selectedIndex;
        NSUInteger selectedSection = self.selectedSection;

		[tabListTabsView reloadData];
		[tabListTabsView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:selectedSection]
									 animated:NO
							   scrollPosition:UITableViewScrollPositionTop];
    } else if (context == (__bridge void*)kFrameKey) {
		[self setTabListRevealed:self.tabListRevealed animated:NO];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -
#pragma mark API

- (UIViewController *)selectedViewController
{
	NSUInteger selectedIndex = self.selectedIndex;
    NSUInteger selectedSection = self.selectedSection;

	if (selectedIndex != NSNotFound && selectedSection != NSNotFound) {
        NSString *sectionName = [_sectionList objectAtIndex:selectedSection];
        NSArray *ep_list = [_dataSource objectForKey:sectionName];
        NSString *ep_name = [ep_list objectAtIndex:selectedIndex];
        NSDictionary *eps_viewcont = [self.viewControllers objectForKey:sectionName];
       // NSArray *onesec_array = [eps_viewcont objectForKey:ep_name];
        return [eps_viewcont objectForKey:ep_name];
		//return [self.viewControllers objectAtIndex:selectedIndex];
	}

	return nil;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
	[self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController animated:(BOOL)animated
{
    NSUInteger index, t_index, section;
    index = t_index = section = NSNotFound;
    
     NSSortDescriptor *sortDescNumber;
     sortDescNumber = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    
    // NSSortDescriptorは配列に入れてNSArrayに渡す
     NSArray *sortDescArray;
     sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
    
    for (NSString *section_name in _sectionList) {
        NSDictionary *newep_viewconts =  [self.viewControllers objectForKey:section_name];
        //NSArray *ep_list = [_dataSource objectForKey:section_name];
        section = [_sectionList indexOfObject:section_name];
        NSArray *new_viewconts = [newep_viewconts allValues];
        NSArray *keys = [newep_viewconts allKeys];
//        NSArray *new_viewconts = [tmp_new_viewconts sortedArrayUsingDescriptors:sortDescArray];
        
        t_index = [new_viewconts indexOfObject:selectedViewController];
        if (t_index == NSNotFound) {
            continue;
        }
        NSString *key = [keys objectAtIndex:t_index];
        NSArray *sorted_keys = [keys sortedArrayUsingDescriptors:sortDescArray];
        
        index = [sorted_keys indexOfObject:key];
        if (index != NSNotFound) {
            break;
        }
        t_index = NSNotFound;
        index = NSNotFound;
    }
	//NSUInteger index = [self.viewControllers indexOfObject:selectedViewController];

	if (index != NSNotFound && section != NSNotFound) {
		[self setSelectedIndex:index  setSelectedSection:section  animated:animated];
    }
}


#pragma mark -
#pragma mark Core

- (void)setSelectedIndex:(NSUInteger)selectedIndex  setSelectedSection:(NSInteger)selectedSection animated:(BOOL)animated
{
    if (_delegateFlags.willSelectViewController) {
        UIViewController *viewController = nil;

        if (selectedIndex != NSNotFound && selectedSection != NSNotFound) {
            NSString *section_name = [_sectionList objectAtIndex:selectedSection];
            NSArray *ep_list = [_dataSource objectForKey:section_name];
            NSDictionary *ep_viewconts = [self.viewControllers objectForKey:section_name];
            NSString *ep_name = [ep_list objectAtIndex:selectedIndex];
            
            viewController = [ep_viewconts objectForKey:ep_name];
        }

        [self.delegate tabListController:self willSelectViewController:viewController];
    }
    
	self.selectedIndex = selectedIndex;
    self.selectedSection = selectedSection;
    
    NSLog(@"%d %d",selectedIndex, selectedSection);

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		// Hack so as to respect the selected view controller's desired orientation
		if (! [[self selectedViewController] shouldAutorotateToInterfaceOrientation:self.interfaceOrientation]) {
			HHTabListWorkaroundViewController *workaroundViewController = [[HHTabListWorkaroundViewController alloc] init];

			[self presentModalViewController:workaroundViewController animated:NO];
			[self dismissModalViewControllerAnimated:NO];

			[UIViewController attemptRotationToDeviceOrientation];

			HH_RELEASE(workaroundViewController);
		}
	}

	[self setTabListRevealed:NO animated:animated];
}

- (CGRect)topViewControllerFrame
{
	BOOL tabListRevealed = self.tabListRevealed;
	CGRect bounds = [self.view bounds];
	CGRect topViewControllerFrame = bounds;

	if (tabListRevealed) {
		topViewControllerFrame.origin.x += HH_TAB_LIST_WIDTH;
	}

	return topViewControllerFrame;
}

- (void)setTabListRevealed:(BOOL)tabListRevealed animated:(BOOL)animated
{
	BOOL wasTabListRevealed = self.wasTabListRevealed;

    self.tabListRevealed = tabListRevealed;
	self.wasTabListRevealed = tabListRevealed;

	UIView *view = self.view;
	HHTabListTabsView *tabListTabsView = self.tabListTabsView;

	if (tabListRevealed) {
		[view insertSubview:tabListTabsView belowSubview:self.containerView];
	}

	NSUInteger selectedIndex = self.selectedIndex;
    NSUInteger selectedSection = self.selectedSection;

	[tabListTabsView reloadData];
	[tabListTabsView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:selectedSection]
								 animated:animated
						   scrollPosition:UITableViewScrollPositionTop];

	UIViewController *selectedViewController = [self selectedViewController];
	UIViewController *lastSelectedViewController = [self lastSelectedViewController];
	CGRect topViewControllerFrame = [self topViewControllerFrame];

	if (selectedViewController != lastSelectedViewController) {

#if HH_STATUS_BAR_TINT_HACK_ENABLED
        // Ugly hack to keep the status bar tint from changing during animation

        if (OSVersion6OrAbove && animated && (! tabListRevealed) && ([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault)) {
            UINavigationController *lastSelectedNavigationController = nil;

            if ([lastSelectedViewController isKindOfClass:[UINavigationController class]]) {
                lastSelectedNavigationController = (id)lastSelectedViewController;
            }
            else {
                [lastSelectedViewController navigationController];
            }

            if (lastSelectedNavigationController != nil) {
                UIColor *tintColor = lastSelectedNavigationController.navigationBar.tintColor;
                UINavigationController *backgroundNavigationController = objc_getAssociatedObject(self, (__bridge void *)kBackgroundNavigationControllerKey);

                if (backgroundNavigationController == nil) {
                    UIViewController *dummyViewController = HH_AUTORELEASE([[UIViewController alloc] init]);
                    UINavigationController *navigationController = HH_AUTORELEASE([[UINavigationController alloc] initWithRootViewController:dummyViewController]);

                    [self addChildViewController:navigationController];

                    UIView *navigationView = navigationController.view;

                    [view insertSubview:navigationView atIndex:0];
                    [navigationView setAlpha:0.0f];

                    [navigationController didMoveToParentViewController:self];

                    objc_setAssociatedObject(self, (__bridge void*)kBackgroundNavigationControllerKey, navigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

                    backgroundNavigationController = navigationController;
                }

                backgroundNavigationController.navigationBar.tintColor = tintColor;
            }
        }
#endif

		[lastSelectedViewController willMoveToParentViewController:nil];
		[self addChildViewController:selectedViewController];

		self.tabListTabsView.userInteractionEnabled = NO;

		HHTabListContainerView *lastContainerView = self.containerView;
		HHTabListContainerView *selectedContainerView = nil;

		if (selectedViewController != nil) {
			CGRect offscreenFrame = topViewControllerFrame;

			offscreenFrame.origin.x = offscreenFrame.size.width;

			selectedContainerView = HH_AUTORELEASE([[HHTabListContainerView alloc] initWithFrame:offscreenFrame]);

			UIView *selectedView = selectedViewController.view;

			[selectedView setFrame:[selectedContainerView bounds]];
			[selectedView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

			[selectedViewController beginAppearanceTransition:YES animated:NO];
			{
				[selectedContainerView.contentView addSubview:selectedView];
				[view addSubview:selectedContainerView];
			}
			[selectedViewController endAppearanceTransition];

			[selectedViewController didMoveToParentViewController:self];

			self.containerView = selectedContainerView;
		}

		[lastSelectedViewController beginAppearanceTransition:NO animated:NO];
		{
			[lastContainerView removeFromSuperview];
			[lastSelectedViewController.view removeFromSuperview];
		}
		[lastSelectedViewController endAppearanceTransition];

		[lastSelectedViewController removeFromParentViewController];

		void (^animationBlock)(void) = ^{
			self.animationInProgress = YES;

			CGRect lastSelectedFrame = [lastContainerView frame];

			lastSelectedFrame.origin.x = lastSelectedFrame.size.width;

			[lastContainerView setFrame:lastSelectedFrame];
			[selectedContainerView setFrame:topViewControllerFrame];
		};

		void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
			self.animationInProgress = NO;
			self.tabListTabsView.userInteractionEnabled = YES;

			[self installGestureRecognizers];

			self.lastSelectedViewController = selectedViewController;

			if (!self.tabListRevealed) {
				[tabListTabsView removeFromSuperview];
			}

			if (_delegateFlags.didSelectViewController) {
				[self.delegate tabListController:self didSelectViewController:selectedViewController];
			}
		};

		if (animated) {
			[UIView animateWithDuration:HH_TAB_LIST_ANIMATION_DURATION
							 animations:animationBlock
							 completion:completionBlock];
		}
		else {
			animationBlock();
			completionBlock(YES);
		}
	}
	else {
		HHTabListContainerView *containerView = self.containerView;

		void (^animationBlock)(void) = ^{
			self.animationInProgress = YES;

			containerView.frame = topViewControllerFrame;
		};

		void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
			self.animationInProgress = NO;

			if (!self.tabListRevealed) {
				[self.tabListTabsView removeFromSuperview];
			}
		};

		if (animated) {
			[UIView animateWithDuration:HH_TAB_LIST_ANIMATION_DURATION
							 animations:animationBlock
							 completion:completionBlock];
		}
		else {
			animationBlock();
			completionBlock(YES);
		}

		if (tabListRevealed != wasTabListRevealed) {
			[self installGestureRecognizers];
		}
	}

    [self.containerView.contentView setUserInteractionEnabled:(! self.tabListRevealed)];
}

- (void)applicationDidChangeStatusBarFrameNotification:(NSNotification*)notification
{
	[self setTabListRevealed:self.tabListRevealed animated:YES];
}


#pragma mark -
#pragma mark Gestures

- (void)attachPanGestureRecognizerToView:(UIView*)view
{
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																						action:@selector(gestureRecognizerDidPan:)];
    gestureRecognizer.cancelsTouchesInView = YES;
    gestureRecognizer.delaysTouchesBegan = YES;
    gestureRecognizer.delegate = self;

    [view addGestureRecognizer:gestureRecognizer];

	[self.gestureRecognizers addObject:gestureRecognizer];

    HH_RELEASE(gestureRecognizer);
}

- (void)attachTapGestureRecognizerToView:(UIView*)view
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						action:@selector(gestureRecognizerDidTap:)];
    gestureRecognizer.cancelsTouchesInView = YES;
    gestureRecognizer.delaysTouchesBegan = YES;
    gestureRecognizer.delaysTouchesEnded = YES;
    gestureRecognizer.delegate = self;

	[view addGestureRecognizer:gestureRecognizer];

	[self.gestureRecognizers addObject:gestureRecognizer];

	HH_RELEASE(gestureRecognizer);
}

- (void)installGestureRecognizers
{
    [self removeGestureRecognizers];

    UIViewController *selectedViewController = [self selectedViewController];
	UINavigationController *navigationController = selectedViewController.navigationController;

	if (navigationController == nil) {
		if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
			navigationController = (UINavigationController*)selectedViewController;
		}
	}

	if (navigationController != nil) {
		[self attachPanGestureRecognizerToView:navigationController.navigationBar];
	}

    BOOL tabListRevealed = self.tabListRevealed;

    if (tabListRevealed) {
        HHTabListContainerView *containerView = self.containerView;
        
        [self attachTapGestureRecognizerToView:containerView];
        [self attachPanGestureRecognizerToView:containerView];
    }
}

- (void)removeGestureRecognizers
{
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        [gestureRecognizer.view removeGestureRecognizer:gestureRecognizer];
    }

    [self.gestureRecognizers removeAllObjects];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
	BOOL shouldReceiveTouch = (! self.animationInProgress);
	BOOL tabListRevealed = self.tabListRevealed;

	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
		if (! tabListRevealed) {
			shouldReceiveTouch = NO;
		}
	}

    return shouldReceiveTouch;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return self.containerMayPan;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
	return YES;
}

- (void)gestureRecognizerDidPan:(UIPanGestureRecognizer*)gestureRecognizer
{
    if (self.animationInProgress) {
		return;
	}

	UIGestureRecognizerState state = gestureRecognizer.state;

	if (state == UIGestureRecognizerStateBegan) {
		UIView *containerView = self.containerView;

		self.panOriginX = containerView.frame.origin.x;

		[self.view insertSubview:self.tabListTabsView belowSubview:self.containerView];
	}
	else if (state == UIGestureRecognizerStateChanged) {
		UIView *view = self.view;
		CGPoint translation = [gestureRecognizer translationInView:view];
		UIView *containerView = self.containerView;
		CGRect containerViewFrame = [containerView frame];
		CGFloat totalPanX = translation.x;

		containerViewFrame.origin.x = self.panOriginX + totalPanX;

		if (containerViewFrame.origin.x <= 0) {
			containerViewFrame.origin.x = 0;
		}
		else if (containerViewFrame.origin.x >= HH_TAB_LIST_WIDTH) {
			containerViewFrame.origin.x = HH_TAB_LIST_WIDTH;
		}

		[containerView setFrame:containerViewFrame];
	}
	else if ((state == UIGestureRecognizerStateEnded) || (state == UIGestureRecognizerStateCancelled)) {
		UIView *view = self.view;
		CGPoint translation = [gestureRecognizer translationInView:view];
		CGFloat totalPanX = translation.x;

		if (totalPanX < (-1.0 * HH_TAB_LIST_TRIGGER_OFFSET)) {
			[self setTabListRevealed:NO animated:YES];
		}
		else if (totalPanX > HH_TAB_LIST_TRIGGER_OFFSET) {
			[self setTabListRevealed:YES animated:YES];
		}
		else {
			[self setTabListRevealed:self.tabListRevealed animated:YES];
		}
	}
}

- (void)gestureRecognizerDidTap:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self setTabListRevealed:(! self.tabListRevealed) animated:YES];
    }
}


#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		UIViewController *selectedViewController = [self selectedViewController];

		if (selectedViewController != nil) {
			return [selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
		}
	}

	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self setTabListRevealed:self.tabListRevealed animated:NO];
}


#pragma mark -
#pragma mark <UITableViewDataSource>

/**
 * テーブル全体のセクションの数を返す
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionList count];
}

/**
 * 指定されたセクションのセクション名を返す
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionList objectAtIndex:section];
}

/**
 * 指定されたセクションの項目数を返す
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sectionList == nil) {
        return [self.viewControllers count];
    }
    else {
        NSString *sectionName = [_sectionList objectAtIndex:section];
        NSArray *eplist = [_dataSource objectForKey:sectionName];
//        //NSDictionary *ep_views = [self.viewControllers objectForKey:sectionName];
        return [eplist count];
    }
}


//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.viewControllers count];
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    switch(section) {
//        case 0: // 1個目のセクションの場合
//            return @"Season1";
//            break;
//        case 1: // 2個目のセクションの場合
//            return @"Season2";
//            break;
//    }
//    return nil; //ビルド警告回避用
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tabList = @"tabList";
    HHTabListCell *cell = [tableView dequeueReusableCellWithIdentifier:tabList];

	if (cell == nil) {
        cell = [[HHTabListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tabList];
	}

	//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:self.selectionIndicatorImage];

    NSSortDescriptor *sortDescNumber;
    sortDescNumber = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];

    // NSSortDescriptorは配列に入れてNSArrayに渡す
    NSArray *sortDescArray;
    sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
    
    // ソートの実行
   
    
    NSString *section_name = [_sectionList objectAtIndex:indexPath.section];
    NSDictionary *ep_viewconts = [self.viewControllers objectForKey:section_name];
    NSArray *tmp_ep_list = [_dataSource objectForKey:section_name];
    NSArray *ep_list = [tmp_ep_list sortedArrayUsingDescriptors:sortDescArray];
    NSString *ep_name = [ep_list objectAtIndex:indexPath.row];
	UIViewController *selectedViewController = [ep_viewconts objectForKey:ep_name];
    UITabBarItem *item = [selectedViewController tabBarItem];

    cell.textLabel.text = item.title;
	//    cell.iconImage = item.image;

    return cell;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.40 alpha:1.0];
    cell.textLabel.textColor = [UIColor whiteColor];
}


#pragma mark -
#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL result = YES;

    if (_delegateFlags.shouldSelectViewController) {
        NSString *section_name = [_sectionList objectAtIndex:indexPath.section];
        NSDictionary *ep_viewconts = [self.viewControllers objectForKey:section_name];
        NSArray *ep_list = [_dataSource objectForKey:section_name];
        NSString *ep_name = [ep_list objectAtIndex:indexPath.row];
        UIViewController *viewController = [ep_viewconts objectForKey:ep_name];
        
        result = [self.delegate tabListController:self shouldSelectViewController:viewController];
    }
    NSLog(@"%d %d",indexPath.row, indexPath.section);
    if (result) {
        [self setSelectedIndex:indexPath.row  setSelectedSection:indexPath.section animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
      //  NSLog(@"%d %d",indexPath.row, indexPath.section);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)] ;
    tableView.sectionHeaderHeight = headerView.frame.size.height;
    tableView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.50 alpha:1.0];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, headerView.frame.size.width - 20, 22)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    
    [headerView addSubview:label];
    return headerView;
    
}

#pragma mark -
#pragma mark API

- (UIBarButtonItem*)revealTabListBarButtonItem
{
	UIImage *listImage = [UIImage imageNamed:@"list"];
	UIImage *listLandscapeImage = [UIImage imageNamed:@"list-landscape"];
	UIBarButtonItem *revealTabListBarButtonItem = nil;

	if ((listImage != nil) && (listLandscapeImage != nil)) {
		revealTabListBarButtonItem = [[UIBarButtonItem alloc] initWithImage:listImage
														landscapeImagePhone:listLandscapeImage
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(revealTabList:)];


	}
	else {
		revealTabListBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Tabs", @"Tabs")
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(revealTabList:)];
	}

	return revealTabListBarButtonItem;
}

- (IBAction)revealTabList:(id)sender
{
	[self setTabListRevealed:YES animated:YES];
}

@end


@implementation UIViewController (HHTabListController)

- (HHTabListController*)tabListController
{
	if ([self isKindOfClass:[HHTabListController class]]) {
		return (HHTabListController*)self;
	}

	return [self.parentViewController tabListController];
}

@end


@implementation HHTabListView

@end


@implementation HHTabListWorkaroundViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end


#pragma mark -
#pragma mark Functions

static UIInterfaceOrientation HHInterfaceOrientation(void)
{
	return [UIApplication sharedApplication].statusBarOrientation;
}

static CGRect HHCGRectRotate(CGRect rect)
{
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

static CGRect HHScreenBounds(void)
{
	CGRect bounds = [UIScreen mainScreen].bounds;
    
	if (UIInterfaceOrientationIsLandscape(HHInterfaceOrientation())) {
		return HHCGRectRotate(bounds);
	}
    
	return bounds;
}

static CGFloat HHStatusBarHeight(void)
{
	UIApplication *application = [UIApplication sharedApplication];
	CGRect statusBarFrame = [application statusBarFrame];
    
    if (UIInterfaceOrientationIsLandscape(HHInterfaceOrientation())) {
        return statusBarFrame.size.width;
	}
    else {
        return statusBarFrame.size.height;
	}
}