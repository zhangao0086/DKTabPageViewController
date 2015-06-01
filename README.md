# DKTabPageViewController
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview1.gif)
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview2.gif)
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview3.gif)

#### custom animation to text of the top bar
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview4.gif)

#### the top bar is hidden
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview5.gif)

#### support visual effects.
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview6.png)

## Overview
DKTabPageViewController is an UIViewController subclass that support for multiple tab and gestures. Each tab represents a ViewController instance, independent of each other. View supports lazy loading and response viewWillAppear、viewWillDisappear etc methods. Adding support for custom animation to text of the top bar.

----

**v1.3.0 - 04.15.2015:**  
* Add supports for visual effects.

**v1.2.0 - 03.08.2015:**  
* Improved performance.
* Adding support for custom animation to text of the top bar.

**v1.0.0 - 01.18.2015:**  
* Adding support for iOS 6.  


#### Will to do:
* Adding support for loaded from xib(storyboard).
* Adding support for scrollable on the top bar.

## How To Get Started

``` bash
$ pod search DKTabPageViewController

-> DKTabPageViewController (1.3.6)
   DKTabPageViewController is an UIViewController subclass that support for multiple
   tab and gestures.
   pod 'DKTabPageViewController', '~> 1.3.6'
   - Homepage: https://github.com/zhangao0086/DKTabPageViewController
   - Source:   https://github.com/zhangao0086/DKTabPageViewController.git
   - Versions: 1.2.0, 1.1.0, 1.0.0, 0.0.6, 0.0.5, 0.0.4, 0.0.3, 0.0.2, 0.0.1 [master
   repo]
```

Add `#import "DKTabPageViewController.h"` to the top of classes that will use it.  
#### Initialize the DKTabPageViewController with an array of DKTabPageItem.

``` objective-c
NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
for (int i = 0; i < 5; i++) {
    TableViewController *vc = [TableViewController new];
    
    DKTabPageItem *item = [DKTabPageViewControllerItem tabPageItemWithTitle:[NSString stringWithFormat:@"Tab %d" ,i]
                                                             viewController:vc];
    [items addObject:item];
}

DKTabPageViewController *tabPageViewController = [[DKTabPageViewController alloc] initWithItems:items];
```

#### Add the DKTabPageViewController's view as a subview

``` objective-c
[self addChildViewController:tabPageViewController];
[self.view addSubview:tabPageViewController.view];
```

#### Flexible and easy to use interface

``` objective-c
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, readonly) UIViewController *selectedViewController;

/**
 *  Whether show the Tab Bar. Defaults to YES.
 */
@property (nonatomic, assign) BOOL showTabPageBar;

/**
 *  Add additional scroll area around content when contentViewController of view is UIScrollview of subclasses.
 */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/**
 *  Whether allow scroll gestures. Defaults to YES.
 */
@property (nonatomic, assign) BOOL gestureScrollEnabled;

/**
 *  The block to be executed on the page changed.
 */
@property (nonatomic, copy) void (^pageChangedBlock)(NSInteger selectedIndex);
```

#### Customizable the top bar

``` objective-c
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
```

#### Custom scrolling animation of the top bar(as demo)

```objective-c

[tabPageViewController setTabPageBarAnimationBlock:^(DKTabPageViewController *weakTabPageViewController, UIButton *fromButton, UIButton *toButton, CGFloat progress) {
    
    // animated font
    CGFloat pointSize = weakTabPageViewController.tabPageBar.titleFont.pointSize;
    CGFloat selectedPointSize = 18;
    
    fromButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * (1 - progress)];
    toButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * progress];
    
    // animated text color
    CGFloat red, green, blue;
    [weakTabPageViewController.tabPageBar.titleColor getRed:&red green:&green blue:&blue alpha:NULL];
    
    CGFloat selectedRed, selectedGreen, selectedBlue;
    [weakTabPageViewController.tabPageBar.selectedTitleColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:NULL];
    
    [fromButton setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * (1 - progress)
                                              green:green + (selectedGreen - green) * (1 - progress)
                                               blue: blue + (selectedBlue - blue) * (1 - progress)
                                              alpha:1] forState:UIControlStateSelected];
    
    [toButton setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * progress
                                            green:green + (selectedGreen - green) * progress
                                             blue:blue + (selectedBlue - blue) * progress
                                            alpha:1] forState:UIControlStateNormal];
}];

```

## Special Thanks
Thanks for your contribution!
<a href="https://github.com/tatey" target="_blank">Tate Johnson</a>

## License
This code is distributed under the terms and conditions of the <a href="https://github.com/zhangao0086/DKTabPageViewController/master/LICENSE">MIT license</a>.