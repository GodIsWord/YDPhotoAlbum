//
//  YDScanerNaviViewController.m
//  二维码
//
//  Created by yide zhang on 2018/10/14.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "YDScanerNaviViewController.h"
#import "YDScanerViewController.h"

@interface YDScanerNaviViewController ()

@end

@implementation YDScanerNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.barTintColor = [UIColor blackColor];
    [self initControllor];
}

-(void)initControllor
{
    YDScanerViewController *group = [[YDScanerViewController alloc] init];
    self.viewControllers = @[group];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
