//
//  ViewController.m
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "ViewController.h"

#import <Photos/Photos.h>
#import "YDPhotoGroupViewController.h"
#import "YDPhotoAlbumNaviViewController.h"

@interface ViewController ()<YDPhotoAlbumViewControllerDelegate>

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
    YDPhotoAlbumNaviViewController *controller = [[YDPhotoAlbumNaviViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
    controller.finishDelegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}


-(void)photoAlbumSelectedViewController:(UIViewController *)controller result:(NSArray *)resultes
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:resultes.firstObject]];
    imageView.frame = CGRectMake(10, 200, 200, 300);
    [self.view addSubview:imageView];
}



@end
