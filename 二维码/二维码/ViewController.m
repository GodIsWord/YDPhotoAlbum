//
//  ViewController.m
//  二维码
//
//  Created by yidezhang on 2018/8/22.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "ViewController.h"
#import "YDScanerNaviViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addButn];
}

-(void)addButn
{
    UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    Btn.frame = CGRectMake(100,100, 100, 100);
    [self.view addSubview:Btn];
    Btn.backgroundColor = [UIColor redColor];
    [Btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)btnAction
{
    YDScanerNaviViewController *navi = [[YDScanerNaviViewController alloc] init];
    [self presentViewController:navi animated:YES completion:nil];
}


@end







