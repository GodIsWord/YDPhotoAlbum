//
//  ViewController.m
//  公告滚动
//
//  Created by yidezhang on 2018/11/15.
//  Copyright © 2018 yidezhang. All rights reserved.
//

#import "ViewController.h"

#import "JFNoticeScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addSubbView];
}


- (void)addSubbView
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    
    JFNoticeScrollView *scrodd = [[JFNoticeScrollView alloc] initWithFrame:CGRectMake(100, 200, 200, 80)];
    scrodd.backgroundColor = [UIColor yellowColor];
    scrodd.showItemCount = 1;
    scrodd.duration = 5;
    scrodd.dataSource = @[@"sadffeeaf",@"adddd肯德基啊立刻就分开了的肌肤",@"大方翻领加咖啡",@"斯大林法律界撒疯了接口撒附近考虑到双方的快乐是非法的说法副书记法兰克福老司机啊"];
    [self.view addSubview:scrodd];
    [scrodd reloadViewWithSelectAction:^(NSInteger index) {
        
    }];
    
}

-(void)btnAction
{
    
}

@end
