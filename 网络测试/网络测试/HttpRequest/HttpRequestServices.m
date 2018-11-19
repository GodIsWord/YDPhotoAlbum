//
//  HttpRequestServices.m
//  OLinPiKe
//
//  Created by  on 16/6/1.
//  Copyright © 2016年 alta. All rights reserved.
//

#import "HttpRequestServices.h"
#import "AFHTTPSessionManager.h"

#import "AFNetworkReachabilityManager.h"

@interface HttpRequestServices ()
@property (strong, nonatomic)AFHTTPSessionManager *afnManager;
@end

static HttpRequestServices *service ;
@implementation HttpRequestServices
+(HttpRequestServices*)sharedInstance
{
    @synchronized(self) {
        if (!service) {
            service = [[HttpRequestServices alloc] init];
            service.afnManager = [AFHTTPSessionManager manager];
            service.afnManager.securityPolicy.allowInvalidCertificates = YES;
            service.afnManager.requestSerializer.timeoutInterval = 2;
            service.afnManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json", @"text/json", @"text/javascript",@"text/css", @"application/javascript",@"application/json", @"application/x-www-form-urlencoded", nil];
        }
        return service;
    }
}
+ (void)deleteSharedInstance {
    if (service) {
        service = nil;
    }
}
/**
 网络队列
 */
- (NSOperationQueue *)getNetworkQueue
{
    return self.afnManager.operationQueue;
}

/**
 * 取消请求
 */
-(void)cancel
{
    [self.afnManager.operationQueue cancelAllOperations];
}
/**
 队列开始请求
 */
- (void)go
{
    [self.afnManager.operationQueue setSuspended:NO];
}

//检测网络是否可用
+ (BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork = FALSE;

    switch ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            isExistenceNetwork=FALSE;
            break;
        default:
            isExistenceNetwork=TRUE;
            break;
    }
    return isExistenceNetwork;
}
#pragma mark - get请求
-(void)AFGETRequestHeaderUrl:(NSString*)header appending:(NSString*)appending withParameters:(NSDictionary *)parameters{
    NSString * url = header;
    if (appending.length>0) {
        url = [url stringByAppendingString:appending];
    }
    
    NSLog(@"url:%@",url);
    [self.afnManager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"responsObject:%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        
    }];
}



@end













