//
//  YDPhotoAlbumNaviViewController.m
//  相册
//
//  Created by yidezhang on 2018/8/27.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoAlbumNaviViewController.h"

#import "YDPhotoAlbumManager.h"


@interface YDPhotoAlbumNaviViewController ()<UINavigationControllerDelegate,YDPhotoAlbumViewControllerDelegate>

@end

@implementation YDPhotoAlbumNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initControllor];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initBackButton];
}
-(void)initControllor
{
    [YDPhotoAlbumManager fetchRequestJaris:^(BOOL isCanUsPhotoLibrary, NSString *message) {
        if (!isCanUsPhotoLibrary) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        
                        [[UIApplication sharedApplication] openURL:url];
                        
                    }
                }];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
                [controller addAction:cancleAction];
                [controller addAction:okAction];
                [self presentViewController:controller animated:YES completion:nil];
                
            });
        }
    }];
    
    YDPhotoGroupViewController *group = [[YDPhotoGroupViewController alloc] init];
    YDPhotoAlbumViewController *photo = [[YDPhotoAlbumViewController alloc] init];
    photo.finishDelegate = self;
    __block NSArray *dataSource = nil;
    [YDPhotoAlbumManager fetchCameraRollItems:^(NSArray<PHAsset *> *result) {
        dataSource = result;
        if (dataSource.count>0) {
            photo.dataSouce = dataSource;
            self.viewControllers = @[group,photo];
        }else{
            self.viewControllers = @[group];
        }
    }];
    
}

-(void)initBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame= CGRectMake(10, 0, 25, 25);
    [btn addTarget:self action:@selector(btnClickBack) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"ydhoto_back@2x.png"] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationBar.barTintColor = [UIColor colorWithWhite:0 alpha:0.5];
    
}
-(void)btnClickBack
{
    if (self.visibleViewController == self.viewControllers[0]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)photoAlbumSelectedViewController:(UIViewController*)controller result:(NSArray *)resultes
{
    if ([self.finishDelegate respondsToSelector:@selector(photoAlbumSelectedViewController:result:)]) {
        [self.finishDelegate photoAlbumSelectedViewController:self result:resultes];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
