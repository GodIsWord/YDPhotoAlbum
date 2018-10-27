//
//  JFVideoPlayerView.h
//  播放器
//
//  Created by yidezhang on 2018/9/13.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFVideoPlayerView : UIView

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) UIImageView *thumImageView;

-(instancetype)initWithFrame:(CGRect)frame;

-(void)play;
-(void)pause;

@end
