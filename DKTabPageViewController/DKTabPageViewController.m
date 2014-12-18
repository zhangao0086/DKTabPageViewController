//
//  DKTabPageViewController.m
//  DKTabPageViewController
//
//  Created by ZhangAo on 14-6-12.
//  Copyright (c) 2014年 zhangao. All rights reserved.
//

#import "DKTabPageViewController.h"

#define DKTABPAGE_RGB_COLOR(r,g,b)      [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
CGSize dktabpage_getTextSize(UIFont *font,NSString *text, CGFloat maxWidth){
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: font}
                                             context:nil].size;
        return textSize;
    }
    
    CGSize textSize = [text sizeWithFont:font
                       constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                           lineBreakMode:NSLineBreakByCharWrapping];
    return textSize;
}
#pragma clang diagnostic pop

@interface DKTabPageItem ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation DKTabPageItem

@end

@implementation DKTabPageViewControllerItem

+ (instancetype)tabPageItemWithTitle:(NSString *)title viewController:(UIViewController *)contentViewController{
    DKTabPageViewControllerItem *item = [DKTabPageViewControllerItem new];
    item.title = title;
    item.contentViewController = contentViewController;
    return item;
}

@end

@implementation DKTabPageButtonItem

+ (instancetype)tabPageItemWithButton:(UIButton *)button {
    DKTabPageButtonItem *item = [DKTabPageButtonItem new];
    item.button = button;
    return item;
}

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageBar ()

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat indicatorWidth;

@property (nonatomic, copy) void (^tabChangedBlock)(NSInteger selectedIndex);

@end

@implementation DKTabPageBar

+ (void)initialize {
    if (self == [DKTabPageBar class]) {
        [[DKTabPageBar appearance] setTabBarHeight:40];
        [[DKTabPageBar appearance] setTitleFont:[UIFont systemFontOfSize:14]];
        [[DKTabPageBar appearance] setBackgroundColor:[UIColor whiteColor]];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *defaultSelectionIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
        defaultSelectionIndicatorView.backgroundColor = DKTABPAGE_RGB_COLOR(231, 53, 53);
        
        self.selectionIndicatorView = defaultSelectionIndicatorView;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5,
                                                                 CGRectGetWidth(self.bounds), 0.5)];
    underline.backgroundColor = DKTABPAGE_RGB_COLOR(208, 208, 208);
    [self addSubview:underline];
    
    if (self.items.count != 0) {
        CGFloat currentX = 0;
        CGFloat indicatorWidth = 0;
        self.itemSize = CGSizeMake(CGRectGetWidth(self.bounds) / self.items.count, CGRectGetHeight(self.bounds));
        
        for (int i = 0; i < self.items.count; i++) {
            DKTabPageItem *item = self.items[i];
            UIButton *button;
            
            if ([item isKindOfClass:[DKTabPageViewControllerItem class]]) {
                DKTabPageViewControllerItem *vcItem = (DKTabPageViewControllerItem *)item;
                
                UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [self setupButtonStyleForButton:itemButton];
                itemButton.tag = i;
                [itemButton setTitle:vcItem.title forState:UIControlStateNormal];
                [itemButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                vcItem.button = itemButton;
                itemButton.selected = self.selectedIndex == i;
                
                button = itemButton;
                
                CGFloat titleWidth = dktabpage_getTextSize(self.titleFont, vcItem.title, CGFLOAT_MAX).width + 5;
                if (titleWidth > indicatorWidth) {
                    indicatorWidth = titleWidth;
                }
            } else if ([item isKindOfClass:[DKTabPageButtonItem class]]) {
                DKTabPageButtonItem *buttonItem = (DKTabPageButtonItem *)item;
                [self setupButtonStyleForButton:buttonItem.button];
                
                button = buttonItem.button;
            } else {
                assert(0);
            }
            
            button.frame = CGRectMake(currentX, 0, self.itemSize.width, self.itemSize.height);
            [self addSubview:button];
            currentX += self.itemSize.width;
        }
        
        self.indicatorWidth = indicatorWidth;
        [self addSubview:self.selectionIndicatorView];
        [self setupSelectionIndicatorView];
    }
}

- (void)setItems:(NSArray *)items {
    _items = [items copy];
    
    [self setNeedsDisplay];
}

#pragma mark - private methods

- (void)setupButtonStyleForButton:(UIButton *)button {
    [button setTitleColor:DKTABPAGE_RGB_COLOR(38, 40, 49) forState:UIControlStateNormal];
    [button setTitleColor:DKTABPAGE_RGB_COLOR(231, 53, 53) forState:UIControlStateHighlighted];
    [button setTitleColor:DKTABPAGE_RGB_COLOR(231, 53, 53) forState:UIControlStateSelected];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font = self.titleFont;
}

- (void)setupSelectionIndicatorView {
    CGFloat offset = self.itemSize.width - self.indicatorWidth;
    self.selectionIndicatorView.frame = CGRectMake(self.itemSize.width * self.selectedIndex + offset / 2,
                                                   CGRectGetHeight(self.bounds) - CGRectGetHeight(self.selectionIndicatorView.bounds),
                                                   self.indicatorWidth, CGRectGetHeight(self.selectionIndicatorView.bounds));
}

- (IBAction)onButtonClicked:(UIButton *)button {
    if (button.selected) {
        return;
    }
    
    DKTabPageItem *previousItem = self.items[self.selectedIndex];
    previousItem.button.selected = NO;
    
    self.selectedIndex = button.tag;
    
    DKTabPageItem *selectedItem = self.items[self.selectedIndex];
    selectedItem.button.selected = YES;
    
    [UIView beginAnimations:nil context:nil];
    [self setupSelectionIndicatorView];
    [UIView commitAnimations];
    
    if (self.tabChangedBlock) {
        self.tabChangedBlock(self.selectedIndex);
    }
}

#pragma mark - UIAppearance methods

- (void)setTabBarHeight:(CGFloat)tabBarHeight {
    _tabBarHeight = tabBarHeight;
    
    CGRect frame = self.frame;
    frame.size.height = tabBarHeight;
    self.frame = frame;
    
    [self setNeedsDisplay];
}

- (void)setSelectionIndicatorView:(UIView *)selectionIndicatorView {
    _selectionIndicatorView = selectionIndicatorView;
    
    [self setNeedsDisplay];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    
    super.backgroundColor = backgroundColor;
}

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageViewController () <UIScrollViewDelegate>

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, weak) UIScrollView *mainScrollView;

@end

@implementation DKTabPageViewController

- (instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    if (self) {
        self.items = items;
        
        self.showTabPageBar = YES;
        self.gestureScrollEnabled = YES;
    }
    return self;
}

/**
 *  Fixed bugs for content size incorrect when called _resizeWithOldSuperviewSize on iOS 7
 */
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.mainScrollView.bounds) * self.childViewControllers.count, 0);
    self.mainScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.mainScrollView.bounds) * self.selectedIndex, 0);
    
    [self cleanupSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupTabBar];
    [self setupMainScrollView];
    [self setupItems];
    
    self.selectedIndex = _selectedIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupTabBar {
    if (self.showTabPageBar) {
        DKTabPageBar *tabPageBar = [[DKTabPageBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.tabPageBar.tabBarHeight)];
        
        __weak DKTabPageViewController *weakSelf = self;
        [tabPageBar setTabChangedBlock:^(NSInteger selectedIndex) {
            [weakSelf setSelectedIndexByIndex:selectedIndex];
            weakSelf.mainScrollView.contentOffset = CGPointMake(weakSelf.selectedIndex * CGRectGetWidth(self.mainScrollView.bounds),
                                                                weakSelf.mainScrollView.contentOffset.y);
        }];
        [self.view addSubview:tabPageBar];
        _tabPageBar = tabPageBar;
        [self.tabPageBar setItems:self.items];
    }
}

- (void)setupMainScrollView {
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)];
    mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    mainScrollView.scrollEnabled = self.gestureScrollEnabled;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.delegate = self;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.alwaysBounceVertical = NO;
    mainScrollView.directionalLockEnabled = YES;
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainScrollView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[scrollView]-0-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:@{@"scrollView" : mainScrollView}]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tabPageBar]-0-[scrollView]-0-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:@{@"scrollView" : mainScrollView, @"tabPageBar" : self.tabPageBar}]];
    self.mainScrollView = mainScrollView;
}

- (void)setupItems {
    for (int i = 0; i < self.items.count; i++) {
        DKTabPageItem *item = self.items[i];
        
        if ([item isKindOfClass:[DKTabPageViewControllerItem class]]) {
            DKTabPageViewControllerItem *vcItem = (DKTabPageViewControllerItem *)item;
            [self addChildViewController:vcItem.contentViewController];
        }
    }
}

- (UIViewController *)selectedViewController {
    assert(self.items != nil);
    DKTabPageViewControllerItem *vcItem = self.items[self.selectedIndex];
    if ([vcItem isKindOfClass:[DKTabPageViewControllerItem class]]) {
        return vcItem.contentViewController;
    } else {
        return nil;
    }
}

- (void)setGestureScrollEnabled:(BOOL)gestureScrollEnabled {
    _gestureScrollEnabled = gestureScrollEnabled;
    
    self.mainScrollView.scrollEnabled = gestureScrollEnabled;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.mainScrollView == nil) {
        _selectedIndex = selectedIndex;
    } else {
        self.mainScrollView.contentOffset = CGPointMake(selectedIndex * CGRectGetWidth(self.mainScrollView.bounds), 0);
        [self setSelectedIndexByIndex:selectedIndex];
    }
}

- (void)addConstraintsToView:(UIView *)view forIndex:(NSInteger)index {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.mainScrollView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0
                                                                     constant:0]];
    
    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.mainScrollView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0]];
    
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%.f-[contentView(==superView)]",
                                                                                         index * CGRectGetWidth(self.mainScrollView.bounds)]
                                                                                options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                metrics:nil
                                                                                  views:@{@"contentView" : view,
                                                                                          @"superView" : self.mainScrollView}]];
}

- (void)cleanupSubviews {
    DKTabPageViewControllerItem *selectedItem = self.items[self.selectedIndex];
    for (DKTabPageViewControllerItem *item in self.items) {
        if (item == selectedItem) {
            item.button.selected = YES;
        } else {
            item.button.selected = NO;
            if (item.contentViewController.isViewLoaded) {
                [item.contentViewController.view removeFromSuperview];
            }
        }
    }
}

- (void)setSelectedIndexByIndex:(NSInteger)newIndex{
    DKTabPageViewControllerItem *selectedItem = self.items[newIndex];
    
    if ([selectedItem isKindOfClass:[DKTabPageViewControllerItem class]]) {
        if (selectedItem.contentViewController == nil) return;
        
        NSInteger previousSelectedIndex = _selectedIndex;
        _selectedIndex = newIndex;
        if (self.pageChangedBlock && previousSelectedIndex != newIndex) {
            self.pageChangedBlock(newIndex);
        }
        
        self.tabPageBar.selectedIndex = _selectedIndex;
        [self.mainScrollView addSubview:selectedItem.contentViewController.view];
        [self addConstraintsToView:selectedItem.contentViewController.view forIndex:_selectedIndex];
        [self cleanupSubviews];
    }
}

#pragma mark - UIScrollView delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat factor = contentOffset.x / CGRectGetWidth(scrollView.bounds);
    
    if (self.showTabPageBar) {
        CGFloat offset = self.tabPageBar.itemSize.width - CGRectGetWidth(self.tabPageBar.selectionIndicatorView.bounds);
        
        CGRect frame = self.tabPageBar.selectionIndicatorView.frame;
        frame.origin.x = (CGRectGetWidth(self.tabPageBar.selectionIndicatorView.bounds) + offset) * factor + offset / 2;
        self.tabPageBar.selectionIndicatorView.frame = frame;
    }
    
    NSInteger index = -1;
    if (factor > self.selectedIndex) {
        index = ceil(factor);
    } else if (factor < self.selectedIndex) {
        index = floor(factor);
    }
    if (index != -1 && index < self.childViewControllers.count) {
        DKTabPageViewControllerItem *item = self.items[index];
        [self.mainScrollView addSubview:item.contentViewController.view];
        [self addConstraintsToView:item.contentViewController.view forIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger newIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    if (self.selectedIndex != newIndex) {
        [self setSelectedIndexByIndex:newIndex];
    }
}

@end
