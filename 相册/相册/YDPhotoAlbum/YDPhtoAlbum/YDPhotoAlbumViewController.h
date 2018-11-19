//
//  YDPhotoAlbumViewController.h
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol YDPhotoAlbumViewControllerDelegate<NSObject>

@optional

/**
 选择图片之后结束的回传 数组里存放的是nsdata
 @param resultes 选中的图片data
 */
-(void)photoAlbumSelectedViewController:(UIViewController*)controller result:(NSArray *)resultes;

@end


@interface YDPhotoAlbumViewController : UIViewController

@property(nonatomic,strong) NSArray *dataSouce;

@property(nonatomic, weak) id <YDPhotoAlbumViewControllerDelegate> finishDelegate;

@end
