# DKTabPageViewController
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview1.gif)
![GIF](https://raw.githubusercontent.com/zhangao0086/DKTabPageViewController/master/preview2.gif)
## Overview
DKTabPageViewController is an UIViewController subclass that support for multiple tab and gestures.

## How To Get Started

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

## License
This code is distributed under the terms and conditions of the <a href="https://github.com/zhangao0086/DKTabPageViewController/master/LICENSE">MIT license</a>.