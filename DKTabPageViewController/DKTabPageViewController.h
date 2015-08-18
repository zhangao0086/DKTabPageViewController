//
//  DKTabPageViewController.h
//  DKTabPageViewController
//
//  Created by ZhangAo on 14-6-12.
//  Copyright (c) 2014年 zhangao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DKTabPageBar;

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageItem : NSObject

@property (nonatomic, readonly) UIButton *button;

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageViewControllerItem : DKTabPageItem

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIViewController *contentViewController;

+ (instancetype)tabPageItemWithTitle:(NSString *)title
                      viewController:(UIViewController *)contentViewController;

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageButtonItem : DKTabPageItem

+ (instancetype)tabPageItemWithButton:(UIButton *)button;

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageBar : UIView

/**
 *  Height of the tab bar. Defautls to 40.
 */
@property (nonatomic, assign) CGFloat tabBarHeight UI_APPEARANCE_SELECTOR;

/**
 * Height of the selected indicator. Defaults to 3.
 */
@property (nonatomic, assign) CGFloat selectedIndicatorHeight UI_APPEARANCE_SELECTOR;

/**
 * Color of the selected indicator. Defaults to an orange-red color.
 */
@property (nonatomic, copy) UIColor *selectedIndicatorColor UI_APPEARANCE_SELECTOR;

/**
 *  Font of the tab bar. Defautls to [UIFont systemFontOfSize:14].
 */
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) UIColor *titleColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) UIColor *selectedTitleColor UI_APPEARANCE_SELECTOR;

/**
 * Color of the 1 point shadow underline. Defaults to a gray color.
 */
@property (nonatomic, copy) UIColor *shadowColor UI_APPEARANCE_SELECTOR;

/**
 *  The selection indicator is draw on bottom of the tab bar.
 */
@property (nonatomic, strong) UIView *selectionIndicatorView;

@end

////////////////////////////////////////////////////////////////////////////////
@class DKTabPageViewController;

typedef void(^TabPageBarAnimationBlock)(DKTabPageViewController *weakTabPageViewController, UIButton *fromButton, UIButton *toButton, CGFloat progress);

@interface DKTabPageViewController : UIViewController

- (instancetype)initWithItems:(NSArray *)items;

@property (nonatomic, readonly) DKTabPageBar *tabPageBar;
@property (nonatomic, copy, readonly) NSArray *items;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, readonly) UIViewController *selectedViewController;

/**
 *  Whether show the Tab Bar. Defaults to YES.
 */
@property (nonatomic, assign) BOOL showTabPageBar;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

/**
 *  Whether allow scroll gestures. Defaults to YES.
 */
@property (nonatomic, assign) BOOL gestureScrollEnabled;

/**
 *  The block to be executed on the page changed.
 */
@property (nonatomic, copy) void (^pageChangedBlock)(NSInteger selectedIndex);

/**
 *  The block to be executed on the selectionIndicatorView of the tab bar in scrolling.
 */
@property (nonatomic, copy) TabPageBarAnimationBlock tabPageBarAnimationBlock;

@end
