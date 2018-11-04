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
-(void)YDPhotoAlbumViewControllerSelectFinishResult:(NSArray *)resultes;

@end


@interface YDPhotoAlbumViewController : UIViewController

@property(nonatomic,strong) NSArray *dataSouce;

@property(nonatomic, weak) id <YDPhotoAlbumViewControllerDelegate> finishDelegate;

@end
