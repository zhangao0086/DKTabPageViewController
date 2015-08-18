//
//  DKTabPageViewController.m
//  DKTabPageViewController
//
//  Created by ZhangAo on 14-6-12.
//  Copyright (c) 2014年 zhangao. All rights reserved.
//

#import "DKTabPageViewController.h"

#define DKTABPAGE_RGB_COLOR(r,g,b)                [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define DKTABPAGE_IOS_VERSION_GREATER_THAN_7      ([[[UIDevice currentDevice] systemVersion] intValue] >= 7)
#define DKTABPAGE_IOS_VERSION_GREATER_THAN_8      ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
CGSize dktabpage_getTextSize(UIFont *font,NSString *text, CGFloat maxWidth){
    if (DKTABPAGE_IOS_VERSION_GREATER_THAN_7) {
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName: font}
                                             context:nil].size;
        return textSize;
    } else {
        CGSize textSize = [text sizeWithFont:font
                           constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)
                               lineBreakMode:NSLineBreakByCharWrapping];
        return textSize;
    }
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
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat indicatorWidth;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger previousSelectedIndex;

@property (nonatomic, copy) void (^tabChangedBlock)(NSInteger selectedIndex);

@end

@implementation DKTabPageBar

+ (void)initialize {
    if (self == [DKTabPageBar class]) {
        [[DKTabPageBar appearance] setTabBarHeight:40];
        [[DKTabPageBar appearance] setTitleFont:[UIFont systemFontOfSize:14]];
        [[DKTabPageBar appearance] setTitleColor:DKTABPAGE_RGB_COLOR(38, 40, 49)];
        [[DKTabPageBar appearance] setSelectedTitleColor:DKTABPAGE_RGB_COLOR(231, 53, 53)];
        [[DKTabPageBar appearance] setSelectedIndicatorColor:DKTABPAGE_RGB_COLOR(255, 99, 99)];
        [[DKTabPageBar appearance] setSelectedIndicatorHeight:3.0];
        [[DKTabPageBar appearance] setShadowColor:DKTABPAGE_RGB_COLOR(208, 208, 208)];
        [[DKTabPageBar appearance] setBackgroundColor:[UIColor whiteColor]];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectionIndicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.itemSize = CGSizeMake(CGRectGetWidth(self.bounds) / self.items.count, CGRectGetHeight(self.bounds));
    CGFloat currentX = 0;
    for (int i = 0; i < self.items.count; i++) {
        DKTabPageItem *item = self.items[i];
        UIButton *button;
        
        if ([item isKindOfClass:[DKTabPageViewControllerItem class]]) {
            DKTabPageViewControllerItem *vcItem = (DKTabPageViewControllerItem *)item;
            
            button = vcItem.button;
        } else if ([item isKindOfClass:[DKTabPageButtonItem class]]) {
            DKTabPageButtonItem *buttonItem = (DKTabPageButtonItem *)item;
            
            button = buttonItem.button;
        } else {
            assert(0);
        }
        
        button.frame = CGRectMake(currentX, 0, self.itemSize.width, self.itemSize.height);
        currentX += self.itemSize.width;
    }
    
    [self setupSelectionIndicatorView];
}

- (void)drawRect:(CGRect)rect {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5,
                                                                 CGRectGetWidth(self.bounds), 0.5)];
    shadow.backgroundColor = self.shadowColor;
    shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:shadow];
    
    if (self.items.count != 0) {
        CGFloat indicatorWidth = 0;
        
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
            
            [self addSubview:button];
        }
        
        self.indicatorWidth = indicatorWidth;
        [self addSubview:self.selectionIndicatorView];
        [self setupSelectionIndicatorView];
        
        if (self.tabChangedBlock) {
            self.tabChangedBlock(self.selectedIndex);
        }
    }
}

- (void)setItems:(NSArray *)items {
    _items = [items copy];
    
    [self setNeedsDisplay];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.previousSelectedIndex == selectedIndex) {
        return;
    }

    _selectedIndex = selectedIndex;
    
    UIButton *selectedButton = [self.items[_selectedIndex] button];
    selectedButton.selected = YES;
    [self setupButtonStyleForButton:selectedButton];
    
    if (self.previousSelectedIndex != NSNotFound) {
        UIButton *previousSelectedButton = [self.items[self.previousSelectedIndex] button];
        previousSelectedButton.selected = NO;
        [self setupButtonStyleForButton:previousSelectedButton];
    }
    
    self.previousSelectedIndex = self.selectedIndex;
}

- (void)onScrollingForOffsetFactor:(CGFloat)factor {
    if (self.selectionIndicatorView != nil) {
        CGFloat offset = self.itemSize.width - CGRectGetWidth(self.selectionIndicatorView.bounds);
        
        CGRect frame = self.selectionIndicatorView.frame;
        frame.origin.x = (CGRectGetWidth(self.selectionIndicatorView.bounds) + offset) * factor + offset / 2;
        self.selectionIndicatorView.frame = frame;
    }
}

#pragma mark - private methods

- (void)setupButtonStyleForButton:(UIButton *)button {
    [button setTitleColor:self.titleColor forState:UIControlStateNormal];
    [button setTitleColor:self.selectedTitleColor forState:UIControlStateHighlighted];
    [button setTitleColor:self.selectedTitleColor forState:UIControlStateSelected];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font = self.titleFont;
}

- (void)setupSelectionIndicatorView {
    if (self.selectionIndicatorView == nil) {
        return;
    }
    CGFloat offset = self.itemSize.width - self.indicatorWidth;
    self.selectionIndicatorView.frame = CGRectMake(self.itemSize.width * self.selectedIndex + offset / 2,
                                                   CGRectGetHeight(self.bounds) - CGRectGetHeight(self.selectionIndicatorView.bounds),
                                                   self.indicatorWidth, self.selectedIndicatorHeight);
    self.selectionIndicatorView.backgroundColor = self.selectedIndicatorColor;
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

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    
    [self setNeedsDisplay];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    
    [self setNeedsDisplay];
}

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageScrollView : UIScrollView {
    BOOL contentViewIsAlready;
}

@property (nonatomic, strong) UIView *contentView;

@end

@implementation DKTabPageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_contentView];
        
        NSDictionary *viewDict = NSDictionaryOfVariableBindings(_contentView, self);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView(==self)]|" options:0 metrics:0 views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView(==self)]|" options:0 metrics:0 views:viewDict]];
        contentViewIsAlready = YES;
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if (!contentViewIsAlready) {
        [super addSubview:view];
    } else {
        [self.contentView addSubview:view];
    }
}

- (void)addConstraint:(NSLayoutConstraint *)constraint {
    if (!contentViewIsAlready) {
        [super addConstraint:constraint];
    } else {
        [self.contentView addConstraint:constraint];
    }
}

- (void)addConstraints:(NSArray *)constraints {
    if (!contentViewIsAlready) {
        [super addConstraints:constraints];
    } else {
        [self.contentView addConstraints:constraints];
    }
}

- (void)removeConstraints:(NSArray *)constraints {
    if (!contentViewIsAlready) {
        [super removeConstraints:constraints];
    } else {
        [self.contentView removeConstraints:constraints];
    }
}

- (NSArray *)constraints {
    return self.contentView.constraints;
}

@end

////////////////////////////////////////////////////////////////////////////////

@interface DKTabPageViewController () <UIScrollViewDelegate>

@property (nonatomic, copy, readwrite) NSArray *items;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) DKTabPageBar *tabPageBar;
@property (nonatomic, assign) UIEdgeInsets scrollViewContentInsets;
@property (nonatomic, strong) NSLayoutConstraint *mainScrollViewConstraintY;

@property (nonatomic, assign) NSInteger previousSelectedIndex;

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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.showTabPageBar) {
        CGRect tabPageBarFrame = self.tabPageBar.frame;
        tabPageBarFrame.size.width = CGRectGetWidth(self.view.bounds);
        self.tabPageBar.frame = tabPageBarFrame;
    }
    
    self.contentInsets = self.contentInsets;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.mainScrollView.isTracking && !self.mainScrollView.dragging) {
        self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.mainScrollView.bounds) * self.childViewControllers.count, 0);
        self.mainScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.mainScrollView.bounds) * self.selectedIndex, 0);
        
        /**
         *  Fixed bugs for content size incorrect when called _resizeWithOldSuperviewSize on iOS 7
         */
        if (!DKTABPAGE_IOS_VERSION_GREATER_THAN_8) {
            [self cleanupSubviews];
        }
        
        if (self.selectedViewController) {
            [self.mainScrollView removeConstraints:self.mainScrollView.constraints];
            [self addConstraintsToView:self.selectedViewController.view forIndex:self.selectedIndex];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.mainScrollView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:@{@"scrollView" : self.mainScrollView}]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mainScrollView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    self.mainScrollViewConstraintY = [NSLayoutConstraint constraintWithItem:self.mainScrollView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0];
    self.mainScrollView.scrollsToTop = NO;
    [self.view addConstraint:self.mainScrollViewConstraintY];
    
    [self setupTabBar];
    [self setupItems];
    
    self.selectedIndex = _selectedIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    // ...
}

#pragma mark - Methods

- (void)setTabPageBarAnimationBlock:(TabPageBarAnimationBlock)tabPageBarAnimationBlock {
    _tabPageBarAnimationBlock = tabPageBarAnimationBlock;
    
    if (self.tabPageBar.layer.contents != nil) {
        self.tabPageBar.tabChangedBlock(self.selectedIndex);
    }
}

- (DKTabPageBar *)tabPageBar {
    if (_tabPageBar == nil) {
        _tabPageBar = [DKTabPageBar new];
    }
    return _tabPageBar;
}

- (void)setupTabBar {
    if (self.showTabPageBar) {
        self.tabPageBar.frame = CGRectMake(0, CGRectGetMinY(self.tabPageBar.frame), 0, self.tabPageBar.tabBarHeight);
        
        __weak DKTabPageViewController *weakSelf = self;
        [self.tabPageBar setTabChangedBlock:^(NSInteger selectedIndex) {
            if (weakSelf.tabPageBarAnimationBlock) {
                DKTabPageItem *selectedItem = weakSelf.items[weakSelf.selectedIndex];
                DKTabPageItem *willToSelectItem = weakSelf.items[selectedIndex];
                weakSelf.tabPageBarAnimationBlock(weakSelf, selectedItem == willToSelectItem ? nil : selectedItem.button, willToSelectItem.button, 1);
            }
            
            weakSelf.selectedIndex = selectedIndex;
        }];
        [self.view addSubview:self.tabPageBar];
        [self.tabPageBar setItems:self.items];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    
    if (self.showTabPageBar) {
        CGRect tabPageBarframe = self.tabPageBar.frame;
        tabPageBarframe.origin.y = contentInsets.top;
        self.tabPageBar.frame = tabPageBarframe;
    }
    
    [self calculateScrollViewContentInsets];
    if (self.selectedViewController) {
        if ([self.selectedViewController isViewLoaded]) {
            [self setupContentInsetsForView:self.selectedViewController.view];
        }
    }
}

- (void)calculateScrollViewContentInsets {
    if (self.showTabPageBar) {
        self.scrollViewContentInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.tabPageBar.frame), self.contentInsets.left,
                                                        self.contentInsets.bottom, self.contentInsets.right);
    } else {
        self.scrollViewContentInsets = self.contentInsets;
    }
}

- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        if (DKTABPAGE_IOS_VERSION_GREATER_THAN_7) {
            _mainScrollView = [[UIScrollView alloc] init];
        } else {
            _mainScrollView = [[DKTabPageScrollView alloc] init];
        }
        _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainScrollView.scrollEnabled = self.gestureScrollEnabled;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.alwaysBounceVertical = NO;
        _mainScrollView.directionalLockEnabled = YES;
        _mainScrollView.backgroundColor = [UIColor clearColor];
        _mainScrollView.delaysContentTouches = NO;
    }
    return _mainScrollView;
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
    if (selectedIndex < 0 || selectedIndex >= self.items.count) {
        return;
    }

    self.mainScrollView.contentOffset = CGPointMake(selectedIndex * CGRectGetWidth(self.mainScrollView.bounds), 0);
    [self setSelectedIndexByIndex:selectedIndex];
}

- (void)addConstraintsToView:(UIView *)view forIndex:(NSInteger)index {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:view.superview
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0
                                                                     constant:0]];
    
    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:view.superview
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0]];
    
    [self.mainScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%.f-[contentView(==superView)]",
                                                                                         index * CGRectGetWidth(self.mainScrollView.bounds)]
                                                                                options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                metrics:nil
                                                                                  views:@{@"contentView" : view,
                                                                                          @"superView" : view.superview}]];
    [self setupContentInsetsForView:view];
}

- (void)setupContentInsetsForView:(UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        
        if (!(scrollView.contentInset.top >= self.scrollViewContentInsets.top &&
              scrollView.contentInset.bottom <= self.scrollViewContentInsets.bottom)) {
            
            scrollView.contentInset = self.scrollViewContentInsets;
            scrollView.scrollIndicatorInsets = self.scrollViewContentInsets;
            
            scrollView.contentOffset = CGPointMake(0, -scrollView.contentInset.top);
        }
    } else {
        if (self.showTabPageBar) {
            self.mainScrollViewConstraintY.constant = self.tabPageBar.tabBarHeight;
        } else {
            self.mainScrollViewConstraintY.constant = 0;
        }
    }
}

- (void)cleanupSubviews {
    for (UIView *subview in self.mainScrollView.subviews) {
        if (subview != self.selectedViewController.view) {
            [subview removeFromSuperview];
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
        
        if (self.showTabPageBar) {
            self.tabPageBar.selectedIndex = newIndex;
        }
        
        if (selectedItem.contentViewController.view.superview == nil) {
            [self.mainScrollView addSubview:selectedItem.contentViewController.view];
            [self addConstraintsToView:selectedItem.contentViewController.view forIndex:_selectedIndex];
        }
        [self cleanupSubviews];
    }
    
    self.previousSelectedIndex = newIndex;
}

#pragma mark - UIScrollView delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.mainScrollView.isDragging && !self.mainScrollView.decelerating) {
        return;
    }
    
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat factor = contentOffset.x / CGRectGetWidth(scrollView.bounds);
    
    NSInteger willToIndex = -1;
    if (factor > (self.showTabPageBar ? self.tabPageBar.selectedIndex : self.selectedIndex)) {
        willToIndex = ceil(factor);
    } else if (factor < (self.showTabPageBar ? self.tabPageBar.selectedIndex : self.selectedIndex)) {
        willToIndex = floor(factor);
    }
    
    if (willToIndex == -1 || willToIndex >= self.childViewControllers.count) {
        willToIndex = NSNotFound;
    }
    
    if (willToIndex != NSNotFound) {
        DKTabPageViewControllerItem *item = self.items[willToIndex];
        if (item.contentViewController.view.superview == nil) {
            [self.mainScrollView addSubview:item.contentViewController.view];
            [self addConstraintsToView:item.contentViewController.view forIndex:willToIndex];
        }
    }
    
    if (self.showTabPageBar && (scrollView.isDecelerating || scrollView.isDragging)) {
        if (self.tabPageBarAnimationBlock) {
            __weak DKTabPageViewController *weakSelf = self;
            CGFloat progress = ABS(factor - self.tabPageBar.selectedIndex);
            if (progress >= 1.00) {
                progress -= 1.00;
                self.tabPageBar.selectedIndex = round(factor);
                self.tabPageBarAnimationBlock(weakSelf, nil, [self.items[self.tabPageBar.selectedIndex] button], 1);
            } else {
                DKTabPageItem *selectedItem = self.items[self.tabPageBar.selectedIndex];
                DKTabPageItem *willToSelectItem;
                if (willToIndex != NSNotFound) {
                    willToSelectItem = self.items[willToIndex];
                    if (![willToSelectItem isKindOfClass:[DKTabPageViewControllerItem class]]) {
                        willToSelectItem = nil;
                    }
                }
                self.tabPageBarAnimationBlock(weakSelf, selectedItem.button, willToSelectItem.button, progress);
            }
        }
        [self.tabPageBar onScrollingForOffsetFactor:factor];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger newIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    if (self.selectedIndex != newIndex) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(selectedIndex))];
        [self setSelectedIndexByIndex:newIndex];
        [self didChangeValueForKey:NSStringFromSelector(@selector(selectedIndex))];
    }
    [self cleanupSubviews];
}

@end
