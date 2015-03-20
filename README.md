# DKTabPageViewController
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview1.gif)
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview2.gif)
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview3.gif)
#### custom animation to text of the top bar
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/1.2.0/preview4.gif)
#### the top bar is hidden
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/1.2.0/preview5.gif)
## Overview
DKTabPageViewController is an UIViewController subclass that support for multiple tab and gestures. Each tab represents a ViewController instance, independent of each other. View supports lazy loading and response viewWillAppear、viewWillDisappear etc methods. Adding support for custom animation to text of the top bar.

----

**v1.0.0 - 01.18.2015:**  
* Adding support for iOS 6.  

**v1.2.0 - 03.08.2015:**  
* Improved performance.
* Adding support for custom animation to text of the top bar.

#### Will to do:
* Adding support for loaded from xib(storyboard).
* Adding support for scrollable on the top bar.

## How To Get Started

``` bash
$ pod search DKTabPageViewController

-> DKTabPageViewController (1.2.1)
   DKTabPageViewController is an UIViewController subclass that support for multiple
   tab and gestures.
   pod 'DKTabPageViewController', '~> 1.2.1'
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
 *  Font of the tab bar. Defautls to [UIFont systemFontOfSize:14].
 */
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

/**
 *  The selection indicator is draw on bottom of the tab bar.
 */
@property (nonatomic, strong) UIView *selectionIndicatorView;

@property(nonatomic, copy) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
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

## License
This code is distributed under the terms and conditions of the <a href="https://github.com/zhangao0086/DKTabPageViewController/master/LICENSE">MIT license</a>.