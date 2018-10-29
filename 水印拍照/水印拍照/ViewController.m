//
//  ViewController.m
//  水印拍照
//
//  Created by yide zhang on 2018/10/27.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "ViewController.h"
#import "YDCamoraViewController.h"
#import "YDLoacationManager.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn setTitle:@"打开相机" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)btnAction
{
    YDCamoraViewController *camora = [[YDCamoraViewController alloc] init];
    [self presentViewController:camora animated:YES completion:nil];
}






@end
