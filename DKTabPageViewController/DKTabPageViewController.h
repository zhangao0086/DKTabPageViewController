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
//
//@protocol DKTabPageBarAnimationDelegate <NSObject>
//
//- (void)tabPageBar:(DKTabPageBar *)tabPageBar scrollingFromButton:(UIButton *)fromButton
//          toButton:(UIButton *)toButton progress:(CGFloat)progress;
//
//@end

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
 *  Font of the tab bar. Defautls to [UIFont systemFontOfSize:14].
 */
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) UIColor *titleColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) UIColor *selectedTitleColor UI_APPEARANCE_SELECTOR;

/**
 *  The selection indicator is draw on bottom of the tab bar.
 */
@property (nonatomic, strong) UIView *selectionIndicatorView;

@property (nonatomic, copy) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
//
//@property (nonatomic, assign) id<DKTabPageBarAnimationDelegate> delegate;

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageViewController : UIViewController

- (instancetype)initWithItems:(NSArray *)items;

@property (nonatomic, readonly) DKTabPageBar *tabPageBar;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, readonly) UIViewController *selectedViewController;

/**
 *  Whether show the Tab Bar. Defaults to YES.
 */
@property (nonatomic, assign) BOOL showTabPageBar;

/**
 *  Whether allow scroll gestures. Defaults to YES.
 */
@property (nonatomic, assign) BOOL gestureScrollEnabled;

/**
 *  The block to be executed on the page changed.
 */
@property (nonatomic, copy) void (^pageChangedBlock)(NSInteger selectedIndex);

@property (nonatomic, copy) void (^tabPageBarAnimationBlock)(UIButton *fromButton, UIButton *toButton, CGFloat progress);

@end
