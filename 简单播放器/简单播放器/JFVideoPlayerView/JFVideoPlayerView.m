//
//  JFVideoPlayerView.m
//  播放器
//
//  Created by yidezhang on 2018/9/13.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "JFVideoPlayerView.h"

#import <AVFoundation/AVFoundation.h>

#import "JFYDPlayerProgressView.h"

//#import <AFNetworking/AFNetworking.h>

#define  IS_IPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)



typedef NS_ENUM(NSUInteger, JFVideoPlayerUISetStatus) {
    JFVideoPlayerUISetStatusPlay,
    JFVideoPlayerUISetStatusPause,
    JFVideoPlayerUISetStatusOrigin,
    JFVideoPlayerUISetStatusLoading,
    JFVideoPlayerUISetStatusFaile,
    JFVideoPlayerUISetStatusFullScreen,
};

typedef NS_ENUM(NSUInteger, JFVideoPlayStatus) {
    JFVideoPlayStatusPlaying,
    JFVideoPlayStatusPause,
    JFVideoPlayStatusLoading,
    JFVideoPlayStatusFailed,
};

@interface JFVideoPlayerView()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) JFYDPlayerProgressView *bottomView;

@property (nonatomic, assign) CGFloat videoDuration;

@property (nonatomic, strong) UIButton *centerPlayBtn;

@property (nonatomic, strong)  id timeObser;

@property (nonatomic, assign) CGRect orgFrame;

@property (nonatomic, weak) UIView *orgSuperView;

@property (nonatomic, strong) UILabel *tishiLabel;//播放失败的提示

@property (nonatomic, strong) UIImageView *refreshView;

@property (nonatomic, assign) BOOL isLoacationVideo;

@property (nonatomic, assign) JFVideoPlayStatus playStatus;

@property (nonatomic, assign) BOOL isFullScreen;//是否全屏

@property (nonatomic, assign) NSString  *lastURL;


@property (nonatomic, assign) BOOL isRigistAPP;//是否退出后台了




@end

@implementation JFVideoPlayerView

-(void)dealloc
{
    [self removeDelegateNotic];
    [self removeVideoNotic];
}
- (void)removeVideoNotic {
    
    [self removeVideoTimerObserver];
    
    //释放掉对playItem的观察
    [self.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull" context:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:_player.currentItem];
    
}

-(void)removeDelegateNotic
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"homeViewWillDisappear" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        [self createBottomView];
        [self createCenterBtn];
        [self creatTishiLabel];
        [self addAppDelegateNotic];
        [self resetBottomStatus:JFVideoPlayerUISetStatusOrigin];
    }
    return self;
}

-(void)setVideoURL:(NSURL *)videoURL
{
    _isLoacationVideo = ![videoURL.absoluteString containsString:@"http"];
    if ([_videoURL.absoluteString isEqualToString:videoURL.absoluteString] && !(self.playStatus == JFVideoPlayStatusFailed)) {
        return;
    }
    _videoURL = videoURL;
    
    [self resetBottomStatus:JFVideoPlayerUISetStatusOrigin];
}

// 添加视频播放器
- (void)loadVideoPlayer{
    
    if ([_lastURL isEqualToString:self.videoURL.absoluteString]) {
        [self play];
        return;
    }else{
        _lastURL = self.videoURL.absoluteString;
    }
    
    if (self.videoURL.absoluteString.length<=0) {
        [self resetBottomStatus:JFVideoPlayerUISetStatusFaile];
        return;
    }
    
    if (self.player) {
        [self removeVideoNotic];
        self.player = nil;
        self.playerItem = nil;
    }
    
    
    [self resetBottomStatus:JFVideoPlayerUISetStatusOrigin];
    
    
    
    self.playerItem = [AVPlayerItem playerItemWithURL:self.videoURL];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    if (!self.playerLayer) {
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerLayer.frame = self.bounds;
        
        [self.layer addSublayer:self.playerLayer];
        
        [self bringSubviewToFront:self.centerPlayBtn];
        [self bringSubviewToFront:self.tishiLabel];
        [self bringSubviewToFront:self.bottomView];
        
        
    }else{
        self.playerLayer.player = self.player;
    }
    
    
    self.videoDuration = CMTimeGetSeconds(self.playerItem.asset.duration);
    self.bottomView.currDuration = 0;
    self.bottomView.totleDuration = self.videoDuration;
    self.bottomView.sliderView.value = 0;
    self.bottomView.progressView.progress = 0.0f;

    [self addObbserve];
    
}

-(void)addObbserve
{
    // 添加观察
    [self loadPlayerObserver];
    
    // 播放状态通知
    [self loadPlayStatusNoti];
    
    [self addVideoTimerObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeViewWillDisappear) name:@"homeViewWillDisappear" object:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)  name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
}
-(void)homeViewWillDisappear
{
    [self setHalfScreen];
    [self orgPause];
}
-(void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"耳机插入");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //耳机拔出
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pause];
            });
            break;
    }
}

-(void)createBottomView
{
    JFYDPlayerProgressView *bottom = [[JFYDPlayerProgressView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 30)];
    [self addSubview:bottom];
    self.bottomView = bottom;
    
    self.bottomView.totleDuration = self.videoDuration;
    self.bottomView.currDuration = 0;
    
    [self.bottomView.playBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView.fullScreenBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView.sliderView addTarget:self action:@selector(sliderChangeBegin:) forControlEvents:UIControlEventTouchDown];
    [self.bottomView.sliderView addTarget:self action:@selector(sliderChangeExit:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)createCenterBtn{
    
    self.thumImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.thumImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.thumImageView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 60);
    [btn setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"puase"] forState:UIControlStateSelected];
    btn.backgroundColor = [UIColor clearColor];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self addSubview:btn];
    btn.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.centerPlayBtn = btn;
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)creatTishiLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    label.text = @"播放失败，请检查网络！";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self addSubview:label];
    self.tishiLabel = label;
    self.tishiLabel.hidden = YES;
}

#pragma mark ------- 播放和暂停状态
-(void)resetBottomStatus:(JFVideoPlayerUISetStatus)type
{
    NSLog(@"11111111111111111111111111111 %lu",(unsigned long)type);
    switch (type) {
        case JFVideoPlayerUISetStatusPlay:
        {
            //播放
            self.playStatus = JFVideoPlayStatusPlaying;
            
            self.bottomView.playBtn.selected = YES;
            self.centerPlayBtn.hidden = YES;
            self.centerPlayBtn.selected = YES;
            self.tishiLabel.hidden = YES;
            
            self.bottomView.hidden = NO;
            
            [self stopRefresh];
            self.refreshView.hidden = YES;
            self.thumImageView.hidden = YES;
        }
        break;
        case JFVideoPlayerUISetStatusPause:
        {
            //暂停
            self.playStatus = JFVideoPlayStatusPause;
            self.bottomView.playBtn.selected = NO;
            self.centerPlayBtn.hidden = NO;
            self.centerPlayBtn.selected = NO;
            self.tishiLabel.hidden = YES;
            
            self.bottomView.hidden = NO;
            
            [self stopRefresh];
            self.refreshView.hidden = YES;
            self.thumImageView.hidden = YES;
        }
        break;
        case JFVideoPlayerUISetStatusOrigin:
        {
            //暂停 播放器重置
            self.playStatus = JFVideoPlayStatusPause;
            self.bottomView.playBtn.selected = NO;
            
            self.tishiLabel.hidden = YES;
            
            self.bottomView.hidden = YES;
            
            [self startRefresh];
            self.refreshView.hidden = YES;
            
            self.thumImageView.hidden = NO;
            [self bringSubviewToFront:self.thumImageView];
            self.centerPlayBtn.hidden = NO;
            self.centerPlayBtn.selected = NO;
            [self bringSubviewToFront:self.centerPlayBtn];
        }
        break;
        case JFVideoPlayerUISetStatusLoading:
        {
            //加载中
            NSLog(@"11111111111111111111111111111startAnimation");
            self.centerPlayBtn.hidden = YES;
            self.bottomView.playBtn.selected = YES;
            self.tishiLabel.hidden = YES;
            
            [self bringSubviewToFront:self.refreshView];
            self.refreshView.hidden = NO;
            [self startRefresh];
            
            self.bottomView.hidden = NO;
            
            self.playStatus = JFVideoPlayStatusLoading;
            
            self.thumImageView.hidden = YES;
        }
        break;
        case JFVideoPlayerUISetStatusFaile:
        {
            self.centerPlayBtn.hidden = YES;
            self.centerPlayBtn.selected = NO;
            self.thumImageView.hidden = YES;
            
            self.bottomView.playBtn.selected = NO;
            self.tishiLabel.hidden = NO;
            
            self.refreshView.hidden = YES;
            [self stopRefresh];
            
            self.bottomView.hidden = YES;
            self.playStatus = JFVideoPlayStatusFailed;
            
        }
        break;
        case JFVideoPlayerUISetStatusFullScreen:
        {
            self.centerPlayBtn.hidden = YES;
            self.thumImageView.hidden = YES;
            
            self.bottomView.playBtn.selected = YES;
            self.tishiLabel.hidden = YES;
            
            self.refreshView.hidden = YES;
            [self stopRefresh];
            
            self.bottomView.hidden = NO;
            self.playStatus = JFVideoPlayStatusPlaying;
            
            [self bringSubviewToFront:self.bottomView];
            [self bringSubviewToFront:self.tishiLabel];
            
        }
            break;
        
        default:
        break;
    }
}

#pragma mark ------------ 播放控制
-(void)play
{
//    AFNetworkReachabilityStatus netStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
//    switch (netStatus) {
//        case AFNetworkReachabilityStatusReachableViaWiFi:
//        {
            [self.player play];
            [self resetBottomStatus:JFVideoPlayerUISetStatusPlay];
            self.playStatus = JFVideoPlayStatusPlaying;
//        }
//            break;
//        case AFNetworkReachabilityStatusReachableViaWWAN:
//        {
//            BOOL isCanPlay = [[[NSUserDefaults standardUserDefaults] valueForKey:@"videoPlayWhen4G"] boolValue];
//            if (isCanPlay) {
//                [self.player play];
//                [self resetBottomStatus:JFVideoPlayerUISetStatusPlay];
//                self.playStatus = JFVideoPlayStatusPlaying;
//            }else{
//                //弹框提示
//                UIAlertController *control = [UIAlertController alertControllerWithTitle:nil message:@"播放将消耗流量，是否继续播放？" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"继续播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"videoPlayWhen4G"];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//
//                    [self.player play];
//                    [self resetBottomStatus:JFVideoPlayerUISetStatusPlay];
//                    self.playStatus = JFVideoPlayStatusPlaying;
//                }];
//                [control addAction:cancleAction];
//                [control addAction:okAction];
//
//                UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                [viewController presentViewController:control animated:NO completion:nil];
//            }
//
//
//        }
//            break;
//        case AFNetworkReachabilityStatusNotReachable:
//        case AFNetworkReachabilityStatusUnknown:
//        {
//            [self resetBottomStatus:JFVideoPlayerUISetStatusFaile];
//        }
//            break;
//
//        default:
//            break;
//    }
    
}
-(void)pause
{
    [self.player pause];
    [self resetBottomStatus:JFVideoPlayerUISetStatusPause];
    self.playStatus = JFVideoPlayStatusPause;
}
-(void)orgPause
{
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player pause];
    [self resetBottomStatus:JFVideoPlayerUISetStatusOrigin];
}
-(void)playFaileState
{
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player pause];
    [self resetBottomStatus:JFVideoPlayerUISetStatusFaile];
}
#pragma mark ---- 增加播放状态的通知监听
- (void)loadPlayStatusNoti{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFailed) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFailed) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:_player.currentItem];
}

//播放结束
- (void)playbackFinished{
    NSLog(@"11111111111111111111111111111播放结束");
    [self setHalfScreen];
    [self orgPause];
}

//播放失败
- (void)playerFailed{
    NSLog(@"11111111111111111111111111111播放失败");
    [self setHalfScreen];
    [self playFaileState];
}


#pragma mark -- 底部按钮对播放器的控制的事件

-(void)btnAction:(UIButton*)btn
{
    if(btn == self.bottomView.playBtn){
        
        btn.selected = !btn.selected;
        if(btn.selected){
            if (self.playStatus != JFVideoPlayStatusFailed) {
                [self play];
            }else{
                btn.selected = !btn.selected;
            }
        }else{
            [self pause];
        }
        
    }else if(btn == self.bottomView.fullScreenBtn){
        
        btn.selected = !btn.selected;
        self.bottomView.fullScreenBtn.selected ? [self setFullScreen] : [self setHalfScreen] ;
        
    }else if(btn == self.centerPlayBtn){
        
        [self loadVideoPlayer];
        
    }
}

-(void)sliderChangeBegin:(UISlider*)slider
{
    NSLog(@"11111111111111111111111111111slider Begin");
    if (self.playStatus != JFVideoPlayStatusFailed) {
        [self pause];
    }
}

-(void)sliderChangeExit:(UISlider*)slider
{
    NSLog(@"11111111111111111111111111111slider end,%f",slider.value*self.videoDuration);
    if (self.playStatus == JFVideoPlayStatusFailed) {
        slider.value = 0;
    }else{
        [self.player seekToTime:CMTimeMake(slider.value*self.videoDuration, 1)];
        if (self.isLoacationVideo || [self buffDuration]+0.5>=self.videoDuration) {
            [self play];
        }else{
            [self resetBottomStatus:JFVideoPlayerUISetStatusLoading];
        }
    }
}

#pragma mark - TimerObserver
- (void)addVideoTimerObserver {
    __weak typeof (self)weakSelf = self;
    _timeObser = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:NULL usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        weakSelf.bottomView.currDuration = current;
        float currentTimeValue = current/self.videoDuration;
        weakSelf.bottomView.sliderView.value = currentTimeValue;
        if (current+0.5 >= weakSelf.videoDuration) {
            weakSelf.isLoacationVideo = YES;
            
        }
    }];
}
- (void)removeVideoTimerObserver {
    [_player removeTimeObserver:_timeObser];
}


#pragma mark ----- 增加播放界面的kvo监听

- (void)loadPlayerObserver{
    
    /**以上是基本的播放界面，但是没有前进后退**/
    //观察是否播放，KVO进行观察，观察playerItem.status
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取更改后的状态
        
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"11111111111111111111111111111ReadyToPlay");
            if (!self.isRigistAPP) {
                [self play];
            }
        } else if (status == AVPlayerStatusFailed) {
            // 播放失败
            NSLog(@"11111111111111111111111111111StatusFailed");
            [self playFaileState];
        } else {
            // 播放失败
            NSLog(@"11111111111111111111111111111StatusFailed");
            [self playFaileState];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        NSLog(@"11111111111111111111111111111下载进度，%f",[self buffDuration]);
        float bufferTime = [self buffDuration];
        float durationTime = CMTimeGetSeconds([[self.player currentItem] duration]);
        [self.bottomView.progressView setProgress:bufferTime/durationTime animated:NO];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        
        NSLog(@"11111111111111111111111111111缓冲不足暂停了");
        if(self.playStatus == JFVideoPlayStatusPlaying){
            [self resetBottomStatus:JFVideoPlayerUISetStatusLoading];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        NSLog(@"11111111111111111111111111111缓冲达到可播放程度了");
        if(self.playStatus == JFVideoPlayStatusPlaying || self.playStatus == JFVideoPlayStatusLoading){
            [self play];
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        
        NSLog(@"11111111111111111111111111111缓冲区满了");
    }
}

#pragma mark -- app打开关闭
-(void)addAppDelegateNotic
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)appResignAction
{
    //app推出焦点
    [self setHalfScreen];
    [self orgPause];
    self.isRigistAPP = YES;
}
- (void)appBecomeActive
{
    //app进入焦点
//    if (self.playStatus == JFVideoPlayStatusPlaying) {
//        [self play];
//    }
    self.isRigistAPP = NO;
}

#pragma mark -- 全屏的控制
-(void)setFullScreen
{
    
    self.isFullScreen = YES;
    self.backgroundColor = [UIColor blackColor];
    self.orgFrame = self.frame;
    if (self.superview && ![self.superview isKindOfClass:UIWindow.class]) {
        self.orgSuperView = self.superview;
        [self removeFromSuperview];
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    BOOL  centerBtnSel = self.centerPlayBtn.hidden;
    self.centerPlayBtn.hidden = YES;
    
    self.thumImageView.hidden = YES;
    
    self.bottomView.fullScreenBtn.selected = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, 0, keyWindow.bounds.size.width, keyWindow.bounds.size.height);
        self.playerLayer.frame = self.bounds;
        self.playerLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    } completion:^(BOOL finished) {
        self.centerPlayBtn.hidden = centerBtnSel;
    }];
}
-(void)setHalfScreen
{
    if (!self.orgSuperView) {
        return;
    }
    
    self.isFullScreen = NO;

    self.backgroundColor = self.orgSuperView.backgroundColor;
    
    CGRect frame = [self.orgSuperView convertRect:self.orgFrame toView:self.superview];
    self.bottomView.fullScreenBtn.selected = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
        self.thumImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.centerPlayBtn.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.playerLayer.frame = self.bounds;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.frame = self.orgFrame;
        [self.orgSuperView addSubview:self];
    }];
}
//加载进度
- (float)buffDuration
{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

-(void)startRefresh
{
    if (!_refreshView) {
        _refreshView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _refreshView.image = [UIImage imageNamed:@"uvv_common_ic_loading_icon"];
        [self addSubview:_refreshView];
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 1.5;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = MAXFLOAT;
        [_refreshView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
    }else{
        [self bringSubviewToFront:_refreshView];
        _refreshView.hidden = NO;
        [_refreshView startAnimating];
    }
    if (self.bottomView.fullScreenBtn.selected) {
        _refreshView.center = CGPointMake(self.frame.size.height/2, self.frame.size.width/2);
    }else{
        _refreshView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}
-(void)stopRefresh
{
    [self.refreshView stopAnimating];
    self.refreshView.hidden = YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.bottomView.frame = CGRectMake(0, self.bounds.size.height-30-((IS_IPHONEX&&self.isFullScreen)?30:0), self.bounds.size.width, 30);
    self.tishiLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.centerPlayBtn.center = self.tishiLabel.center;
    self.thumImageView.frame = self.bounds;
    self.refreshView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}
@end
