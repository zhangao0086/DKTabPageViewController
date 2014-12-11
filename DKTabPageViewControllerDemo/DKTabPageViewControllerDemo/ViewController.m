//
//  ViewController.m
//  DKTabPageViewControllerDemo
//
//  Created by 张奥 on 14-12-10.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

#import "ViewController.h"
#import "DKTabPageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        UITableViewController *vc = [UITableViewController new];
        
        DKTabPageItem *item = [DKTabPageViewControllerItem tabPageItemWithTitle:[NSString stringWithFormat:@"Tab %d" ,i]
                                                                 viewController:vc];
        [items addObject:item];
    }
    
    DKTabPageViewController *tabPageViewController = [[DKTabPageViewController alloc] initWithItems:items];
    [self addChildViewController:tabPageViewController];
    [self.view addSubview:tabPageViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
