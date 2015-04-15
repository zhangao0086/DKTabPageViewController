//
//  ViewController.m
//  DKTabPageViewControllerDemo
//
//  Created by 张奥 on 14-12-10.
//  Copyright (c) 2014年 ZhangAo. All rights reserved.
//

#import "ViewController.h"
#import "DKTabPageViewController.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        TableViewController *vc = [TableViewController new];
        
        DKTabPageItem *item = [DKTabPageViewControllerItem tabPageItemWithTitle:[NSString stringWithFormat:@"Tab %d" ,i]
                                                                 viewController:vc];
        [items addObject:item];
    }
    
    // add extra button
    UIButton *extraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [extraButton setTitle:@"Extra" forState:UIControlStateNormal];
    [extraButton addTarget:self action:@selector(extraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:[DKTabPageButtonItem tabPageItemWithButton:extraButton]];
    
    DKTabPageViewController *tabPageViewController = [[DKTabPageViewController alloc] initWithItems:items];
//    tabPageViewController.showTabPageBar = NO;
    tabPageViewController.contentInsets = UIEdgeInsetsMake(44, 0, 0, 0);
    [self addChildViewController:tabPageViewController];
    [self.view addSubview:tabPageViewController.view];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)extraButtonClicked:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:@"This is a extra button"
                               delegate:nil
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles: nil]
     show];
}

@end
