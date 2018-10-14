//
//  YDScanWebViewController.h
//  OLinPiKe
//
//  Created by  on 16/6/21.
//  Copyright © 2016年 zhangyide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ARCatalog.h"

typedef enum {
    FromTypeViewController , //从普通的viewcontroller跳转过来的 默认
    FromTypeViewUnityDaoHang ,//从导航的unity页面过来的
    FromTypeViewUnityXiYin //鸟巢吸引切换的页面
} FromPageType ;

typedef NS_ENUM(NSUInteger, ArtaWebLoadType) {
    ArtaWebLoadTypeWebUrl =0,
    ArtaWebLoadTypeLoacalH5
};

@interface YDScanWebViewController : UIViewController

@property (nonatomic,strong) NSURL *loadURL;
@property (nonatomic,strong) NSString *loadHTMLString;
@property (nonatomic,assign) FromPageType fromPage;//来源的类型
@property (nonatomic,assign) ArtaWebLoadType loadType;

@end



@interface ArtaWebProgressView : UIView
@property (nonatomic ,assign) float time;
@property (nonatomic ,assign) BOOL isWebEndAnmation;
@property (nonatomic ,assign) BOOL isWebStartAnmation;
@property (nonatomic ,assign) BOOL animationFinish;
@property (nonatomic ,assign) NSInteger yanshi;
@property (nonatomic ,assign) float progress;
@property (nonatomic ,strong) UIView * progressView;
@property (nonatomic ,assign) float progressHeight;
-(void)shouldStartLoadWithRequestProgressAnimation;
-(void)webViewDidFinishLoadProgressAnimation;
-(void)webViewDidStartLoadProgressAnimation;
-(instancetype)initWithFrame:(CGRect)frame progressHeight:(float)height;
@end
