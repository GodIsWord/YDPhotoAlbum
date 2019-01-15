//
//  JFTimeListScrollView.m
//  滚动测试
//
//  Created by yidezhang on 2019/1/8.
//  Copyright © 2019 yidezhang. All rights reserved.
//

#import "JFTimeListScrollView.h"

#define SliderCenterYToBottom 15.0

@interface JFTimeListScrollView()

@property (nonatomic, strong) UISlider *sliderView;

@property (nonatomic, strong) NSMutableArray *timeViewArray;

@property (nonatomic, strong) UIView *timeBackView;


@end

@implementation JFTimeListScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatSubbViews];
    }
    return self;
}
- (void)creatSubbViews {
    
    self.timeViewArray = [NSMutableArray array];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    
    UIView *sliderBackView = [[UIView alloc] initWithFrame:CGRectMake(0, height-SliderCenterYToBottom, width, 5)];
    sliderBackView.layer.cornerRadius = 2.5;
    sliderBackView.jf_centerY = height-SliderCenterYToBottom;
    sliderBackView.backgroundColor = [UIColor jf_colorFromString:@"#D8D9E2" alpha:0.5];
    sliderBackView.jf_centerY = self.jf_height - SliderCenterYToBottom;
    [self addSubview:sliderBackView];
    
    
    self.sliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, self.jf_height - SliderCenterYToBottom, self.bounds.size.width, 30)];
    self.sliderView.center = sliderBackView.center;
    [self addSubview:self.sliderView];
    [self.sliderView addTarget:self action:@selector(sliderChangeExit:) forControlEvents:UIControlEventTouchUpInside];
    self.sliderView.minimumValue = 0;
    self.sliderView.maximumValue = 1;
    [self.sliderView setThumbImage:[UIImage imageNamed:@"滑块"] forState:UIControlStateNormal];
    self.sliderView.minimumTrackTintColor = [UIColor clearColor];
    self.sliderView.maximumTrackTintColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTouchAction:)];
    [self.sliderView addGestureRecognizer:tap];
    
}

- (void)sliderTouchAction:(UITapGestureRecognizer*)tap{
    
    CGPoint point =  [tap locationInView:self.sliderView];
    CGFloat value = point.x / self.sliderView.jf_width * (self.sliderView.maximumValue - self.sliderView.minimumValue) + self.sliderView.minimumValue;
    [self makTouchPosition:value];
}

- (void)sliderChangeExit:(UISlider *)sliderView{
    [self makTouchPosition:sliderView.value];
}

- (void)makTouchPosition:(CGFloat)sliderValue{
    
    NSInteger intValue = (NSInteger)(sliderValue);
    if (intValue>=self.dataSource.count) {
        intValue = self.dataSource.count - 1;
    }
    self.sliderView.value = intValue + 0.5;
    
    for (JFTimeListScrollTimeItemView *itemView  in self.timeViewArray) {
        itemView.select = [self.timeViewArray indexOfObject:itemView] == intValue;
    }
    if (self.callBack) {
        self.callBack(intValue);
    }
}

- (void)reloadDate
{
    
    if (self.timeViewArray.count == self.dataSource.count || self.dataSource.count <= 0) {
        return;
    }
    
    for (UIView *subbView in self.timeViewArray) {
        [subbView removeFromSuperview];
    }
    [self.timeViewArray removeAllObjects];
    
    CGFloat cellWidth = self.jf_width / self.dataSource.count;
    
    for (NSInteger i=0; i< self.dataSource.count ; i++) {
        NSNumber *timer = self.dataSource[i];
        JFTimeListScrollTimeItemView *itemView = [[JFTimeListScrollTimeItemView alloc] initWithFrame:CGRectMake(i*cellWidth, 0, cellWidth, self.jf_height)];
        itemView.timeLabel.text = [JFTimeListScrollView coverTimeWithInt:timer];
        [self.timeViewArray addObject:itemView];
        [self addSubview:itemView];
        
        itemView.select = i==self.defaultIndex;
    }
    
    [self bringSubviewToFront:self.sliderView];
    self.sliderView.jf_x = -17.5;
    self.sliderView.jf_width = cellWidth * (self.dataSource.count) + 35;
    self.sliderView.minimumValue = 0;
    self.sliderView.maximumValue = self.dataSource.count;
    self.sliderView.value = 0.5 + self.defaultIndex;
    
    if(self.defaultIndex >0 && self.defaultIndex < self.dataSource.count && self.callBack){
        self.callBack(self.defaultIndex);
    }
}

+ (NSString *)coverTimeWithInt:(NSNumber *)numer{
    
    NSInteger time = numer.integerValue;
    
    if (time % 365 == 0 && time / 365 > 0) {
        return [NSString stringWithFormat:@"%ld年",time / 365];
    }else if(time % 30 == 0 &&  time / 30 >0) {
        return [NSString stringWithFormat:@"%ld个月",time / 30];
    }else{
        return [NSString stringWithFormat:@"%ld天",time];
    }
    
}


@end




@implementation JFTimeListScrollTimeItemView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        pointView.backgroundColor = [UIColor jf_colorFromString:@"#D8D9E2"];
        [self addSubview:pointView];
        pointView.jf_centerY = frame.size.height - SliderCenterYToBottom;
        pointView.jf_centerX = frame.size.width/2.0;
        pointView.layer.cornerRadius = 2.5;
        
        
        _tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 5.7, 3.7)];
        _tagImageView.jf_centerX = self.jf_width/2.0;
        _tagImageView.image = [UIImage imageNamed:@"三角形未选中"];
        _tagImageView.highlightedImage = [UIImage imageNamed:@"三角形选中"];
        [self addSubview:_tagImageView];
        
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.jf_width, 20)];
        _timeLabel.jf_centerX = self.jf_width/2.0;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:SCREEN_WIDTH<=320 ? 8 : 11];
        _timeLabel.textColor = [UIColor jf_colorFromString:@"#81849F"];
        [self addSubview:_timeLabel];
    }
    return self;
}


-(void)setSelect:(BOOL)select{
    _select = select;
    _tagImageView.highlighted = select;
    _timeLabel.textColor = [UIColor jf_colorFromString:select ? @"#2D2F46" : @"#81849F"];;
}

@end


