//
//  XBWeakProxy.h
//  FindSecret
//
//  Created by yidezhang on 2018/7/31.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBWeakProxy : NSProxy

@property (nullable, nonatomic, weak, readonly) id target;


- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end
