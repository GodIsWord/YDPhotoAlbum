//
//  YDLoacationManager.m
//  水印拍照
//
//  Created by yide zhang on 2018/10/29.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDLoacationManager.h"

#import <CoreLocation/CoreLocation.h>

#import "YDCoverLocation.h"

@interface YDLoacationManager()<CLLocationManagerDelegate>

@property (strong,nonatomic) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager* locationMgr;

@property (nonatomic, copy) NSString *address;


@end

@implementation YDLoacationManager

static YDLoacationManager *manager;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YDLoacationManager new];
    });
    return manager;
}

+(void)startWithLoacation
{
    [[YDLoacationManager shareInstance] startLoacation];
}

-(void)startLoacation
{
    if ([self.locationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationMgr requestWhenInUseAuthorization];
        [self.locationMgr startUpdatingLocation];
    }
}

-(CLGeocoder *)geocoder {
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

-(CLLocationManager *)locationMgr {
    if (_locationMgr == nil) {
        _locationMgr = [[CLLocationManager alloc] init];
        _locationMgr.delegate = self;
        _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        _locationMgr.distanceFilter = kCLDistanceFilterNone;
        [_locationMgr requestAlwaysAuthorization];
    }
    return _locationMgr;
}

//获取经纬度
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *cl = [locations objectAtIndex:0];
    /*
     反编码
     */
    //获取经纬度坐标
    
    CLLocationCoordinate2D coordinat = [YDCoverLocation transformFromWGSToGCJ:cl.coordinate];
     
    NSLog(@"gps 经纬度 ：%f,%f",cl.coordinate.longitude,cl.coordinate.latitude);
    NSLog(@"wgs84 经纬度 ：%f,%f",coordinat.longitude,coordinat.latitude);
    
    coordinat = CLLocationCoordinate2DMake(40.074833,116.42471); 
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinat.latitude longitude:coordinat.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            //编码失败，找不到地址
            NSLog(@"没定位到啊");
        }else{
            /*
             编码成功
             */
            CLPlacemark *firstPlacemark = [placemarks firstObject];
            /*
             firstPlacemark.ISOcountryCode  国家编码 ：中国（CN）
             firstPlacemark.country   国家
             firstPlacemark.administrativeArea  省份
             firstPlacemark.locality   城市
             firstPlacemark.subLocality  区
             firstPlacemark.thoroughfare 街道
             firstPlacemark.addressDictionary  字典，包含地址的一些基本信息
             */
//            NSString *address = firstPlacemark.name; //打印结果是当前的街道信息，比如：长安街，北京东路。。。
            NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@,addrass:%@",firstPlacemark.country,(firstPlacemark.administrativeArea ?: @""),firstPlacemark.locality,firstPlacemark.subLocality,firstPlacemark.name,(firstPlacemark.thoroughfare?:@""),(firstPlacemark.subThoroughfare?:@""),(firstPlacemark.areasOfInterest?:@""),firstPlacemark.addressDictionary];
            
            NSLog(@"%@",address);
            NSString *formatAddress = firstPlacemark.addressDictionary.count<=0 ? @"" : [[firstPlacemark.addressDictionary objectForKey:@"FormattedAddressLines"] firstObject];
            NSLog(@"ssssss %@",formatAddress);
            
//            self.address = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
//                            (firstPlacemark.administrativeArea ?: @""),
//                            firstPlacemark.subAdministrativeArea ?: @"",
//                            firstPlacemark.locality,
//                            firstPlacemark.subLocality,
//                            firstPlacemark.name,
//                            (firstPlacemark.thoroughfare?:@""),
//                            (firstPlacemark.subThoroughfare?:@""),
//                            firstPlacemark.areasOfInterest.count>0 ? firstPlacemark.areasOfInterest.firstObject : @""];
            
            self.address = [NSString stringWithFormat:@"%@%@",
                            formatAddress,firstPlacemark.name];
//            self.address = formatAddress;
        }
    }];
}

//地位错误返回
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

+(NSString *)address
{
    return [YDLoacationManager shareInstance].address ?: @"";
}

@end
