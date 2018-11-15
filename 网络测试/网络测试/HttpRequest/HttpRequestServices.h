//
//  HttpRequestServices.h
//  OLinPiKe
//
//  Created by zhangyide on 16/6/1.
//  Copyright © 2016年 alta. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HttpRequestServices : NSObject

+ (instancetype)sharedInstance;
+ (void)deleteSharedInstance;
//检测网络是否可用
+ (BOOL)isExistenceNetwork;

-(void)AFGETRequestHeaderUrl:(NSString*)header appending:(NSString*)appending withParameters:(NSDictionary *)parameters;

@end


