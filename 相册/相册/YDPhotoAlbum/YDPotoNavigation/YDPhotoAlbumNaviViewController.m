//
//  YDPhotoAlbumNaviViewController.m
//  相册
//
//  Created by yidezhang on 2018/8/27.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoAlbumNaviViewController.h"
#import "YDPhotoGroupViewController.h"
#import "YDPhotoAlbumViewController.h"
#import "YDPhotoAlbumManager.h"

@interface YDPhotoAlbumNaviViewController ()<UINavigationControllerDelegate>

@end

@implementation YDPhotoAlbumNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initControllor];
    [self initBackButton];
}

-(void)initControllor
{
    YDPhotoGroupViewController *group = [[YDPhotoGroupViewController alloc] init];
    YDPhotoAlbumViewController *photo = [[YDPhotoAlbumViewController alloc] init];
    __block NSArray *dataSource = nil;
    [YDPhotoAlbumManager fetchCameraRollItems:^(NSArray<PHAsset *> *result) {
        dataSource = result;
    }];
    if (dataSource.count>0) {
        photo.dataSouce = dataSource;
        self.viewControllers = @[group,photo];
    }else{
        self.viewControllers = @[group];
    }
    
}

-(void)initBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame= CGRectMake(10, 0, 25, 25);
    [btn addTarget:self action:@selector(btnClickBack) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[[UIImage imageNamed:@"ydhoto_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationBar.barTintColor = [UIColor redColor];
    
}
-(void)btnClickBack
{
    if (self.visibleViewController == self.viewControllers[0]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
