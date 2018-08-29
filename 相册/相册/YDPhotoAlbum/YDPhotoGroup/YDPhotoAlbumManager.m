//
//  YDPhotoAlbumManager.m
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoAlbumManager.h"
#import <Photos/Photos.h>

@interface YDPhotoAlbumManager()<PHPhotoLibraryChangeObserver>


@end

@implementation YDPhotoAlbumManager

+(void)fetchPhotoGroup:(void (^)(NSArray<YDPhotoGroupModel *> *array))block
{
    [self fetchRequestJaris:^(BOOL isCanUsPhotoLibrary) {
        if (!isCanUsPhotoLibrary) {
            if (block) {
                block(nil);
            }
            return ;
        }
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
        
        PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        [results enumerateObjectsUsingBlock:^(PHAssetCollection*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.localIdentifier.length > 0) {
                
                PHFetchResult *assetArray = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                
                YDPhotoGroupModel *model = [[YDPhotoGroupModel alloc] init];
                model.localIdentifier = obj.localIdentifier;
                model.count = assetArray.count;
                
                model.name = [self transformAblumTitle:obj.localizedTitle];
                
                NSMutableArray *items = [NSMutableArray array];
                [assetArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAsset  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [items addObject:obj];
                }];
                
                model.items = items;
                
                if (assetArray.count>0) {
                    PHAsset *asset = assetArray.firstObject;
                    if (asset.mediaType == PHAssetMediaTypeImage) {
                        CGFloat scale = [UIScreen mainScreen].scale;
                        CGSize cellSize = CGSizeMake(400,400);
                        CGSize assetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
                        
                        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:assetGridThumbnailSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            model.image = result;
                        }];
                        [array addObject:model];
                    }
                }
            }
            if (block) {
                block(array);
            }
        }];
    }];

}

+(void)fetchCameraRollItems:(void (^)(NSArray<PHAsset*> *))block
{
    [self fetchRequestJaris:^(BOOL isCanUsPhotoLibrary) {
        if (!isCanUsPhotoLibrary) {
            if (block) {
                block(nil);
            }
            return ;
        }
        [self fetchPhotoItemsTitle:@"Camera Roll" complate:block];
    }];
}

+(void)fetchPhotoItemsTitle:(NSString *)title complate:(void (^)(NSArray<PHAsset*> *result))block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        if (results.count<=0) {
            if (block) {
                block(nil);
            }
        }
        [results enumerateObjectsUsingBlock:^(PHAssetCollection   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.localizedTitle isEqualToString:title]) {
                
                PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
                NSMutableArray *items = [NSMutableArray array];
                [assets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(PHAsset  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [items addObject:obj];
                }];
                if (block) {
                    block(items);
                }
            }
        }];
    });
}

+(void)fetchHighQualityImageAsset:(PHAsset *)asset viewSize:(CGSize)viewSize progress:(void((^)(double progress)))handle complate:(void((^)(UIImage *result)))complate
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = true;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handle) {
                handle(progress);
            }
        });
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:viewSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (complate) {
            complate(result);
        }
        
    }];
}

+(void)fetchAllPhotos:(void ((^)(NSArray<PHAsset *> *)))block
{
    [self fetchRequestJaris:^(BOOL isCanUsPhotoLibrary) {
        if (!isCanUsPhotoLibrary) {
            if (block) {
                block(nil);
            }
            return ;
        }
        NSMutableArray *array = [NSMutableArray array];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 列出所有相册智能相册
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            
            if (smartAlbums.count != 0) {
                
                //获取资源时的参数
                PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
                //按时间排序
                allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                //所有照片
                PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
                
                for (NSInteger i = 0; i < allPhotos.count; i++) {
                    
                    PHAsset *asset = allPhotos[i];
                    if (asset.mediaType == PHAssetMediaTypeImage) {
                        [array addObject:asset];
                    }
                    
                }
                if (block) {
                    block(array);
                }
            }
        });
    }];
}

//检查是否能用相册
+(void)fetchRequestJaris:(void((^)(BOOL isCanUsPhotoLibrary)))block
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        if (block) {
            block(YES);
        }
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            BOOL isCan = NO;
            if (status == PHAuthorizationStatusDenied) {
                NSLog(@"用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关");
            }else if (status == PHAuthorizationStatusRestricted){
                NSLog(@"家长控制,不允许访问");
            }else if (status == PHAuthorizationStatusNotDetermined){
                NSLog(@"用户还没有做出选择");
                isCan = YES;
            }else if (status == PHAuthorizationStatusAuthorized){
                isCan = YES;
            }
            if (block) {
                block(isCan);
            }
        }];
    }
}

#pragma mark -- observer delegate
-(void)photoLibraryDidChange:(PHChange *)changeInstance
{
    
}


#pragma mark -- 辅助方法

+ (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else if ([title isEqualToString:@"Bursts"]) {
        return @"爆发";
    }else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景";
    }else if ([title isEqualToString:@"Hidden"]) {
        return @"隐藏";
    }else if ([title isEqualToString:@"Time-lapse"]) {
        return @"定时";
    }
    return title;
}


@end
