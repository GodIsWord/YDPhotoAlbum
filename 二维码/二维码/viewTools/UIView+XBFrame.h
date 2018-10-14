//
//  UIView+XBFrame.h
//  FindSecret
//
//  Created by yidezhang on 2018/7/28.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XBFrame)
@property (assign, nonatomic) CGFloat xb_x;
@property (assign, nonatomic) CGFloat xb_y;
@property (assign, nonatomic) CGFloat xb_width;
@property (assign, nonatomic) CGFloat xb_height;

@property (assign, nonatomic) CGFloat xb_left;
@property (assign, nonatomic) CGFloat xb_top;
@property (assign, nonatomic) CGFloat xb_bottom;
@property (assign, nonatomic) CGFloat xb_right;

@property (assign, nonatomic) CGFloat xb_centerX;
@property (assign ,nonatomic) CGFloat xb_centerY;
@property (assign ,nonatomic) CGPoint xb_origin;
@property (assign ,nonatomic) CGSize xb_framSize;

@property (assign ,nonatomic) CGFloat xb_rightToSuper;
@property (assign ,nonatomic) CGFloat xb_bottomToSuper;

@end
