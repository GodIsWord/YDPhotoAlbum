//
//  YDPhotoGroupModel.h
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface YDPhotoGroupModel : NSObject

@property(nonatomic,strong) UIImage *image;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *localIdentifier;
@property(nonatomic,assign) NSInteger count;
@property(nonatomic,copy) NSArray *items;

@end
