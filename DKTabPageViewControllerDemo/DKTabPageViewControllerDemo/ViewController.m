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
    [self addChildViewController:tabPageViewController];
    [self.view addSubview:tabPageViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)extraButtonClicked:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"" message:@"This is a extra button" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil]
     show];
}

@end
