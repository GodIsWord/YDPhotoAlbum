//
//  YDWeakProxy.h
//  CocopodsDemo
//
//  Created by yidezhang on 2018/3/19.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YDWeakProxy : NSProxy
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
@end
