//
//  JFNoticeScrollView.m
//  公告滚动
//
//  Created by yidezhang on 2018/11/15.
//  Copyright © 2018 yidezhang. All rights reserved.
//

#import "JFNoticeScrollView.h"

@interface JFNoticeScrollView()

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) NSTimer *timer;

@property (nonatomic, copy) void(^selectBlock) (NSInteger );

@property (nonatomic, strong) NSMutableArray *itemViewArray;

@property (nonatomic, assign) CGFloat itemHeight;

@property (nonatomic, assign) NSInteger showLastIndex;

@end

@implementation JFNoticeScrollView

-(void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemFont = [UIFont systemFontOfSize:13];
        self.itemStrColor = [UIColor blackColor];
        self.itemViewArray = [NSMutableArray array];
        [self initSubbView];
    }
    return self;
}

-(void)setShowItemCount:(NSInteger)showItemCount
{
    _showItemCount = showItemCount>0 ? showItemCount : 1;
    
}

-(void)setDuration:(CGFloat)duration
{
    _duration = duration<=0 ? 0 : duration;
    if (_timer) {
        [_timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    
}

-(void)timeAction
{
    NSLog(@"sadfd:%d",self.showLastIndex);
    if (self.dataSource.count<=0 || self.itemViewArray.count <= 0) {
        return;
    }
    
    //timer第一次不做操作
    static NSInteger timeCount = 0;
    if (timeCount<=0) {
        timeCount++;
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentOffset = CGPointMake(0, self.itemHeight);
    } completion:^(BOOL finished) {
        if (finished) {
            self.scrollView.contentOffset = CGPointMake(0, 0);
            for (NSInteger i = 0; i < self.itemViewArray.count-1; i++) {
                UILabel *label = self.itemViewArray[i];
                UILabel *nextLabel = self.itemViewArray[i+1];
                label.text = nextLabel.text;
            }
            UILabel *lastLabel = self.itemViewArray.lastObject;
            self.showLastIndex ++ ;
            if (self.showLastIndex >= self.dataSource.count) {
                self.showLastIndex = 0;
            }
            
            lastLabel.text = [self.dataSource objectAtIndex:self.showLastIndex];
        }
    }];
    
    
}
-(void)initSubbView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height * 3);
    
}
-(void)reloadViewWithSelectAction:(void ((^)(NSInteger)))block
{
    self.selectBlock = block;
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemViewArray removeAllObjects];
    
    if (self.dataSource.count <= self.showItemCount) {
        
        [self.timer setFireDate:[NSDate distantFuture]];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        CGFloat itemHeight = self.scrollView.bounds.size.height/self.showItemCount;
        CGFloat itemWidth = self.scrollView.bounds.size.width;
        
        
        for (NSInteger i=0; i < self.dataSource.count; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, itemHeight * i, itemWidth, itemHeight);
            label.text = self.dataSource[i];
            label.textColor = self.itemStrColor;
            label.font = self.itemFont;
            [self.scrollView addSubview:label];
        }
    }else{
        
        [self.timer setFireDate:[NSDate distantPast]];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height/self.showItemCount * (self.showItemCount+1));
        
        CGFloat itemHeight = self.scrollView.bounds.size.height/self.showItemCount;
        CGFloat itemWidth = self.scrollView.bounds.size.width;
        self.itemHeight = itemHeight;
        
        self.showLastIndex = self.showItemCount;
        
        for (NSInteger i=0; i <= self.showItemCount; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(0, itemHeight * i, itemWidth, itemHeight);
            label.text = self.dataSource[i];
            label.textColor = self.itemStrColor;
            label.font = self.itemFont;
            [self.scrollView addSubview:label];
            [self.itemViewArray addObject:label];
        }
    }
}


@end














