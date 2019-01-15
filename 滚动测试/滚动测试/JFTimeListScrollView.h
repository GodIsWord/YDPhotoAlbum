//
//  JFTimeListScrollView.h
//  滚动测试
//
//  Created by yidezhang on 2019/1/8.
//  Copyright © 2019 yidezhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFTimeListScrollView : UIView

@property(nonatomic, copy) NSArray<NSNumber *> *dataSource;

@property(nonatomic, assign) NSInteger defaultIndex;//默认选中

@property (nonatomic, copy) void(^callBack) (NSInteger );

-(void) reloadDate;

+ (NSString *)coverTimeWithInt:(NSNumber *)numer;

@end

NS_ASSUME_NONNULL_END


@interface JFTimeListScrollTimeItemView : UIView

@property (nonatomic, strong) UIImageView * _Nullable tagImageView;
@property (nonatomic, strong) UILabel * _Nullable timeLabel;
@property (nonatomic, assign) BOOL select;

@end
