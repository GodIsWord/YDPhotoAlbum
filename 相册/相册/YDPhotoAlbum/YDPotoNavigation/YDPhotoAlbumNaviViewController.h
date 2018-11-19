//
//  YDPhotoAlbumNaviViewController.h
//  相册
//
//  Created by yidezhang on 2018/8/27.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YDPhotoGroupViewController.h"
#import "YDPhotoAlbumViewController.h"
#import "YDPhotoAlbumManager.h"



@interface YDPhotoAlbumNaviViewController : UINavigationController

@property(nonatomic, weak) id<YDPhotoAlbumViewControllerDelegate> finishDelegate;

@end
