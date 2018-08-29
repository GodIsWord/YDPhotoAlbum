//
//  YDPhotoAlbumCollectionViewCell.h
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDPhotoAlbumCollectionViewCell : UICollectionViewCell

//@property(nonatomic,strong) UILabel *label;
@property(nonatomic,strong) UIImageView *imageView;
//@property (nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, copy) void(^selectBLock)(BOOL isSelect);

@end
