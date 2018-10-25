//
//  UIView+XBFrame.m
//  FindSecret
//
//  Created by yidezhang on 2018/7/28.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "UIView+XBFrame.h"

@implementation UIView (XBFrame)

- (CGFloat)xb_x {
    return CGRectGetMinX(self.frame);
}

- (void)setXb_x:(CGFloat)xb_x {
    self.frame = CGRectMake(xb_x, CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (CGFloat)xb_y {
    return CGRectGetMinY(self.frame);
}

- (void)setXb_y:(CGFloat)xb_y {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), xb_y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (CGFloat)xb_width {
    return CGRectGetWidth(self.frame);
}

- (void)setXb_width:(CGFloat)xb_width {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), xb_width, CGRectGetHeight(self.frame));
}

- (CGFloat)xb_height {
    return CGRectGetHeight(self.frame);
}

- (void)setXb_height:(CGFloat)xb_height {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), xb_height);
}

- (void)setXb_left:(CGFloat)xb_left{
    [self setXb_x:xb_left];
}
- (CGFloat)xb_left{
    return self.xb_x;
}
- (void)setXb_top:(CGFloat)xb_top{
    [self setXb_y:xb_top];
}
- (CGFloat)xb_top{
    return self.xb_y;
}
- (void)setXb_bottom:(CGFloat)xb_bottom{
    CGRect frame = self.frame;
    frame.origin.y = xb_bottom - self.frame.size.height;
    self.frame = frame;
}
- (CGFloat)xb_bottom{
    return CGRectGetMaxY(self.frame);
}

- (void)setXb_right:(CGFloat)xb_right{
    CGRect frame = self.frame;
    frame.origin.x = xb_right - self.frame.size.width;
    self.frame = frame;
}
- (CGFloat)xb_right{
    return CGRectGetMaxX(self.frame);
}


- (CGFloat)xb_centerX {
    
    return self.center.x;
}

- (void)setXb_centerX:(CGFloat)xb_centerX {
    
    self.center = CGPointMake(xb_centerX,self.center.y);
}

- (CGFloat)xb_centerY {
    
    return self.center.y;
}

- (void)setXb_centerY:(CGFloat)xb_centerY {
    
    self.center = CGPointMake(self.center.x,xb_centerY);
}

- (CGPoint)xb_origin
{
    return self.frame.origin;
}

- (void)setXb_origin:(CGPoint)xb_origin
{
    CGRect fram = self.frame;
    fram.origin = xb_origin;
    self.frame = fram;
}


- (CGSize)xb_framSize
{
    return self.frame.size;
}
- (void)setXb_framSize:(CGSize)xb_framSize
{
    CGRect fram = self.frame;
    fram.size = xb_framSize;
    self.frame = fram;
}


- (CGFloat)xb_rightToSuper {
    return self.superview.bounds.size.width-self.frame.size.width-self.frame.origin.x;
}
- (void)setXb_rightToSuper:(CGFloat)xb_rightToSuper {
    
    CGRect frame = self.frame;
    frame.origin.x = self.superview.bounds.size.width-self.frame.size.width-xb_rightToSuper;
    self.frame = frame;
}



- (CGFloat)xb_bottomToSuper {
    
    return self.superview.bounds.size.height-self.frame.size.height-self.frame.origin.y;
}
- (void)setXb_bottomToSuper:(CGFloat)xb_bottomToSuper {
    
    CGRect frame = self.frame;
    frame.origin.y = self.superview.bounds.size.height-self.frame.size.height-xb_bottomToSuper;
    self.frame = frame;
}

@end
