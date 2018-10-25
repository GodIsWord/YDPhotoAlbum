//
//  JFYDPlayerProgressView.h
//  播放器
//
//  Created by yidezhang on 2018/9/13.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JFYDPlayerProgressView : UIView

@property(nonatomic,assign) CGFloat totleDuration;

@property(nonatomic,assign) CGFloat currDuration;

@property(nonatomic,strong) UIButton *playBtn;

@property(nonatomic,strong) UIButton *fullScreenBtn;

@property(nonatomic,strong) UIProgressView *progressView;

@property(nonatomic,strong) UISlider *sliderView;


@end
