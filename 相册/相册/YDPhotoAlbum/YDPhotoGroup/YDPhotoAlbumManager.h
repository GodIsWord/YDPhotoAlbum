//
//  YDPhotoAlbumManager.h
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDPhotoGroupModel.h"

@interface YDPhotoAlbumManager : NSObject


/**
 获取相册组信息

 @param block 回调一个model数组
 */
+(void)fetchPhotoGroup:(void(^)(NSArray<YDPhotoGroupModel*> *array))block;


/**
 获取相机胶卷的所有图片

 @param block 回调
 */
+(void)fetchCameraRollItems:(void(^)(NSArray<PHAsset*> *result))block;


/**
 根据title查询指定相册的所有图片

 @param title title
 @param block 回调
 */
+(void)fetchPhotoItemsTitle:(NSString*)title complate:(void(^)(NSArray<PHAsset*> *result))block;


/**
 获取单一的image

 @param asset 输入的图片数据源
 @param viewSize 设置的分辨率
 @param handle 加载进度
 @param complate 加载完成回调
 */
+(void)fetchHighQualityImageAsset:(PHAsset *)asset viewSize:(CGSize)viewSize  progress:(void((^)(double progress)))handle complate:(void((^)(UIImage *result)))complate;


/**
 获取单一image的data

 @param asset 输入图片数据源
 @param handle 设置加载回调
 @param complate 加载完成回调
 */
+(void)fetchHighQualityImageDataWithAsset:(PHAsset *)asset progress:(void((^)(double progress)))handle complate:(void((^)(NSData *result)))complate;

/**
 获取所有图片资源 只是图片 不包括视频

 @param block 回调数据
 */
+(void)fetchAllPhotos:(void((^)(NSArray<PHAsset*>* result)))block;

@end
