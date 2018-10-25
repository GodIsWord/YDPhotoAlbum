//
//  JFYDPlayerProgressView.m
//  播放器
//
//  Created by yidezhang on 2018/9/13.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "JFYDPlayerProgressView.h"

@interface JFYDPlayerProgressView()

@property(nonatomic,strong) UILabel *totalLabel;

@property(nonatomic,strong) UILabel *currLabel;

@end

@implementation JFYDPlayerProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self createSubbView];
    }
    return self;
}

-(void)setTotleDuration:(CGFloat)totleDuration
{
    _totleDuration = totleDuration;
    _totalLabel.text = [self getStringFromTime:totleDuration];
}
-(void)setCurrDuration:(CGFloat)currDuration
{
    _currDuration = currDuration;
    _currLabel.text = [self getStringFromTime:currDuration];
}

-(void)createSubbView
{
    if (!_sliderView) {
        
        //底部的view
        UIView *backView = self;
        backView.userInteractionEnabled = YES;
        backView.backgroundColor = [UIColor clearColor];
        
        CGFloat btnWidth = 30;
        CGFloat btnHeight = 30;
        
        UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPlay.frame = CGRectMake(0, 0, btnWidth, btnHeight);
        [btnPlay setImage:[UIImage imageNamed:@"uvv_player_player_btn"] forState:UIControlStateNormal];
        [btnPlay setImage:[UIImage imageNamed:@"uvv_stop_btn"] forState:UIControlStateSelected];
        [backView addSubview:btnPlay];
        [btnPlay setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        btnPlay.tag = 3001;
        _playBtn = btnPlay;
        
        UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 40, 20)];
        labelTime.font = [UIFont systemFontOfSize:10];
        labelTime.textColor = [UIColor whiteColor];
        labelTime.text = @"--";
        labelTime.tag = 5002;
        [labelTime setTextAlignment:NSTextAlignmentCenter];
        [backView addSubview:labelTime];
        self.currLabel = labelTime;
        
        
        UIProgressView *progress = [[UIProgressView alloc] initWithFrame:CGRectMake(70, 5, self.frame.size.width-158, 30)];
        progress.progressTintColor = [UIColor colorWithWhite:1 alpha:0.6];
        progress.trackTintColor = [UIColor colorWithWhite:1 alpha:0.1];
        progress.tag = 4003;
        [backView addSubview:progress];
        progress.center = CGPointMake(progress.center.x, 15);
        _progressView = progress;
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(70, 0, self.frame.size.width-158, 50)];
        slider.maximumValue = 1.0;
        slider.minimumValue = 0.0;
        [slider setThumbImage:[UIImage imageNamed:@"progressThumb@2x"] forState:UIControlStateNormal];
        [slider setMaximumTrackTintColor:[UIColor clearColor]];
        [slider setMinimumTrackTintColor:[UIColor whiteColor]];
        slider.tag = 4002;
        [backView addSubview:slider];
        _sliderView = slider;
        slider.center = progress.center;
        
        UILabel *toatleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-85, 5, 40, 20)];
        toatleLabel.font = [UIFont systemFontOfSize:10];
        toatleLabel.textColor = [UIColor whiteColor];
        toatleLabel.tag = 5001;
        toatleLabel.text = @"--";
        [toatleLabel setTextAlignment:NSTextAlignmentCenter];
        [backView addSubview:toatleLabel];
        self.totalLabel = toatleLabel;
        
        UIButton *btnFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFullScreen.frame = CGRectMake(self.frame.size.width-35, 0, 30, 30);
        [btnFullScreen setImage:[UIImage imageNamed:@"uvv_player_scale_btn"] forState:UIControlStateNormal];
        [btnFullScreen setImage:[UIImage imageNamed:@"uvv_star_zoom_in"] forState:UIControlStateSelected];
        [btnFullScreen setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        btnFullScreen.tag = 3002;
        [backView addSubview:btnFullScreen];
        _fullScreenBtn = btnFullScreen;
    }
}



- (NSString *)getStringFromTime:(CGFloat)time
{
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:currentDate];
    
    if (time >= 3600 )
    {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%02ld:%02ld",components.minute,components.second];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playBtn.frame = CGRectMake(0, 0, 30, 30);
    self.progressView.frame = CGRectMake(70, 5, self.frame.size.width-158, 30);
    self.progressView.center = CGPointMake(self.progressView.center.x, 15);
    self.sliderView.frame = CGRectMake(70, 0, self.frame.size.width-158, 50);
    self.sliderView.center = self.progressView.center;
    self.fullScreenBtn.frame = CGRectMake(self.frame.size.width-35, 0, 30, 30);
    self.currLabel.frame = CGRectMake(30, 5, 40, 20);
    self.totalLabel.frame = CGRectMake(self.frame.size.width-85, 5, 40, 20);
}

@end
