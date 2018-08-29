//
//  YDPhotoAlbumCollectionViewCell.m
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoAlbumCollectionViewCell.h"

@interface YDPhotoAlbumCollectionViewCell()

@property (nonatomic, strong) UIButton *btnSign;

@end

@implementation YDPhotoAlbumCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageView];
        
//        _label = [[UILabel alloc] initWithFrame:self.bounds];
//        _label.numberOfLines = 0;
//        _label.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:_label];
        
        UIButton *btnSign = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSign.frame = CGRectMake(_imageView.frame.size.width-30, 0, 30, 30);
        [btnSign setImage:[UIImage imageNamed:@"ydhoto_select_no"] forState:UIControlStateNormal];
        [btnSign setImage:[UIImage imageNamed:@"ydhoto_select_yes"] forState:UIControlStateSelected];
        [btnSign addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnSign setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [_imageView addSubview:btnSign];
        _btnSign = btnSign;
        
//        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(self.bounds.size.width/4, self.bounds.size.height/4*3, self.bounds.size.width/2, self.bounds.size.height/4)];
//        _progressView.progressViewStyle = UIProgressViewStyleDefault;
//        _progressView.progressTintColor = [UIColor blackColor];
//        _progressView.trackTintColor = [UIColor whiteColor];
//        [self.contentView addSubview:_progressView];
        
        
    }
    return self;
}

-(void)btnAction:(UIButton*)btn
{
    btn.selected = !btn.selected;
    [self shakeToShow:btn.imageView];
    if (self.selectBLock) {
        _selectBLock(btn.selected);
    }
}

-(void)shakeToShow:(UIImageView *)button{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [button.layer addAnimation:animation forKey:nil];
}


@end
