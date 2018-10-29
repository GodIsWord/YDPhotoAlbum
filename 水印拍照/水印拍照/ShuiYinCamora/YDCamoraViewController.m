//
//  YDCamoraViewController.m
//  水印拍照
//
//  Created by yide zhang on 2018/10/27.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDCamoraViewController.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight  [UIScreen mainScreen].bounds.size.height

//导入相机框架
#import <AVFoundation/AVFoundation.h>
//将拍摄好的照片写入系统相册中，所以我们在这里还需要导入一个相册需要的头文件iOS8
#import <Photos/Photos.h>
#import "YDWeakProxy.h"

#import "YDLoacationManager.h"

@interface YDCamoraViewController ()

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic,strong)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic,strong)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic,strong)AVCaptureMetadataOutput *output;

//照片输出流
@property (nonatomic,strong)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic,strong)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

// ------------- UI --------------
//拍照按钮
@property (nonatomic,strong)UIButton *photoButton;
//闪光灯按钮
@property (nonatomic,strong)UIButton *flashButton;
//翻转摄像头按钮
@property (nonatomic,strong)UIButton *flapCamora;
//聚焦
@property (nonatomic,strong)UIView *focusView;

//拍摄后图片的imageView
@property (nonatomic,strong) UIImageView *pictureImageView;
@property (nonatomic,strong) UILabel  *timeLabel;//时分秒显示
@property (nonatomic,strong) UILabel  *dateLabel;//日期 年月日显示
@property (nonatomic,strong) UILabel  *userlabel;//用户名称
@property (nonatomic,strong) UILabel  *locationlabel;//定位信息

@property (nonatomic, strong) UIButton *okBtn;//拍照确认使用按钮
@property (nonatomic, strong) UIButton *cancleBtn;//拍照确认使用按钮

@property (nonatomic, strong) UILabel *tishiLabel;//提示用的label

@property (nonatomic, strong) NSTimer *timer;//时间

@end

@implementation YDCamoraViewController

-(void)dealloc
{
    [self.timer invalidate];
    self.timer  = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    [YDLoacationManager startWithLoacation];
    
    if ( [self checkCameraPermission]) {
        
        [self customCamera];
        [self initSubViews];
        
//        [self focusAtPoint:CGPointMake(0.5, 0.5)];
        
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[YDWeakProxy proxyWithTarget:self] selector:@selector(getTimeAndWeakDay) userInfo:nil repeats:YES];
}
- (UILabel *)tishiLabel
{
    if(!_tishiLabel){
        _tishiLabel = [[UILabel alloc] init];
        [self.view addSubview:_tishiLabel];
    }
    [self.view bringSubviewToFront:_tishiLabel];
    return _tishiLabel;
}
-(UIButton *)okBtn
{
    if(!_okBtn){
        _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _okBtn.frame = CGRectMake(KScreenWidth/2+50, KScreenHeight - 150, 70, 70);
        [_okBtn setImage:[UIImage imageNamed:@"post_icon_check_big"] forState:UIControlStateNormal];
        [_okBtn addTarget:self action:@selector(picBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_okBtn];
    }
    [self.view bringSubviewToFront:_okBtn];
    return _okBtn;
}
-(UIButton *)cancleBtn
{
    if(!_cancleBtn){
        _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleBtn.frame = CGRectMake(KScreenWidth/2-50-70, KScreenHeight - 150, 70, 70);
        [_cancleBtn setImage:[UIImage imageNamed:@"post_icon_voice_clear_normal"] forState:UIControlStateNormal];
        [_cancleBtn addTarget:self action:@selector(picBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancleBtn];
    }
    [self.view bringSubviewToFront:_cancleBtn];
    return _cancleBtn;
}
-(void)picBtnAction:(UIButton*)btn
{
    if(btn==self.okBtn){
        //保存图片
        [self saveImageWithImage:[self snapshotSingleView:self.pictureImageView]];
    }else if (btn == self.cancleBtn){
        //取消 继续拍照
        [self hiddenPictureResult];
    }
}
- (void)customCamera
{
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc]init];
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        
    }
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    
    //修改设备的属性，先加锁
    if ([self.device lockForConfiguration:nil]) {

        //闪光灯自动
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }

        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }

        //解锁
        [self.device unlockForConfiguration];
    }
    
}


- (void)initSubViews
{
    [self initTakePictureSubbView];
    [self initPictureShowSubbView];
    
}

//初始化拍照相关的subbView
-(void)initTakePictureSubbView
{
    //头部导航栏的背景
    UIView *headerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    headerBackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    headerBackView.userInteractionEnabled = YES;
    [self.view addSubview:headerBackView];
    
    
    //闪光灯的开关
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.frame = CGRectMake(KScreenWidth-60, 0, 44, 44);
    [self.flashButton setImage:[UIImage imageNamed:@"shanguangdengkai_normal"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"shanguangdengguanbi_normal"] forState:UIControlStateSelected];
    [self.flashButton setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 3)];
    [ self.flashButton addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerBackView addSubview: self.flashButton];
    
    UIView *bottomBackView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight-120, KScreenWidth, 120)];
    bottomBackView.backgroundColor = [UIColor clearColor];
    bottomBackView.userInteractionEnabled = YES;
    [self.view addSubview:bottomBackView];
    
    //拍照
    self.photoButton = [UIButton new];
    self.photoButton.frame = CGRectMake(KScreenWidth/2-35, 0, 70, 70);
    [self.photoButton setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackView addSubview:self.photoButton];
    
    //取消
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(KScreenWidth/2 - 100, 5, 40, 40);
    [btn setImage:[UIImage imageNamed:@"post_icon_xiatui_normal"] forState:UIControlStateNormal];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [btn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(btn.center.x, self.photoButton.center.y);
    [bottomBackView addSubview:btn];
    
    
    
    //翻转摄像头
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.frame = CGRectMake(KScreenWidth/2 + 60, 0, 44, 44);
    [flashButton setBackgroundImage:[UIImage imageNamed:@"post_icon_huanjingtou_normal"] forState:UIControlStateNormal];
    flashButton.center = CGPointMake(flashButton.center.x, self.photoButton.center.y);
    [flashButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackView addSubview:flashButton];
    self.flashButton = flashButton;
    
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.focusView.layer.borderWidth = 1.0;
    self.focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.view addSubview:self.focusView];
    self.focusView.hidden = YES;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
}
//显示拍完照之后的图片的view
- (void)initPictureShowSubbView
{
    UIImageView *imageViewPicture = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageViewPicture.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageViewPicture];
    self.pictureImageView = imageViewPicture;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 44, 4, 75)];
    lineView.backgroundColor = [UIColor whiteColor];
    [imageViewPicture addSubview:lineView];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+5, CGRectGetMinY(lineView.frame), KScreenWidth-100, 20)];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = @"";
    timeLabel.font = [UIFont systemFontOfSize:18];
    [imageViewPicture addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+5, CGRectGetMaxY(timeLabel.frame)+5, KScreenWidth-100, 20)];
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.text = @"";
    dateLabel.font = [UIFont systemFontOfSize:13];
    [imageViewPicture addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineView.frame)+5, CGRectGetMaxY(dateLabel.frame)+5, KScreenWidth-100, 20)];
    addressLabel.textColor = [UIColor whiteColor];
    addressLabel.text =  [YDLoacationManager address];
    addressLabel.font = [UIFont systemFontOfSize:13];
    [imageViewPicture addSubview:addressLabel];
    self.locationlabel = addressLabel;
    
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal fromDate:[NSDate date]];
//    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)components.hour,(long)components.minute];
//    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%02ld月%02ld日 %@",components.year,components.month,components.day,[self formatWeekDayWithType:components.weekday]];
    
}

- (void)showPicturResult
{
    self.okBtn.hidden = NO;
    self.cancleBtn.hidden = NO;
}

- (void)hiddenPictureResult
{
    self.okBtn.hidden = YES;
    self.cancleBtn.hidden = YES;
    self.pictureImageView.image = nil;
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
//    CGPoint point = [gesture locationInView:gesture.view];
//    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    // focusPoint 函数后面Point取值范围是取景框左上角（0，0）到取景框右下角（1，1）之间,按这个来但位置就是不对，只能按上面的写法才可以。前面是点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1 - point.x/size.width );
    
    if ([self.device lockForConfiguration:nil]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            //曝光量调节
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
    }
    
}

- (void)flashAction:(UIButton*)btn{
    btn.selected = !btn.selected;
    if ([_device lockForConfiguration:nil]) {
        if (btn.selected) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
            }
        }else{
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
            }
        }
        
        [_device unlockForConfiguration];
    }
}

- (void)changeCamera{
    //获取摄像头的数量
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    //摄像头小于等于1的时候直接返回
    if (cameraCount <= 1) return;
    
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    //获取当前相机的方向(前还是后)
    AVCaptureDevicePosition position = [[self.input device] position];
    
    //为摄像头的转换加转场动画
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    
    if (position == AVCaptureDevicePositionFront) {
        //获取后置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
    }else{
        //获取前置摄像头
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    
    [self.previewLayer addAnimation:animation forKey:nil];
    //输入流
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    
    
    if (newInput != nil) {
        
        [self.session beginConfiguration];
        //先移除原来的input
        [self.session removeInput:self.input];
        
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.input = newInput;
            
        } else {
            //如果不能加现在的input，就加原来的input
            [self.session addInput:self.input];
        }
        
        [self.session commitConfiguration];
        
    }
    
    
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}


#pragma mark- 拍照
- (void)shutterCamera
{
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection ==  nil) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer == nil) {
            return;
        }
        
        NSData *imageData =  [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        weakSelf.pictureImageView.image = [UIImage imageWithData:imageData];
        [weakSelf showPicturResult];
        
    }];
    
}
/**
 * 保存图片到相册
 */
- (void)saveImageWithImage:(UIImage *)image {
    // 判断授权状态
    __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            
            // 保存相片到相机胶卷
            __block PHObjectPlaceholder *createdAsset = nil;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
                [weakSelf hiddenPictureResult];
                [weakSelf showTishiLabelWithText:@"保存成功"];
            } error:&error];
            
            if (error) {
                [weakSelf showTishiLabelWithText:@"保存失败"];
                NSLog(@"保存失败：%@", error);
                return;
            }
        });
    }];
}
-(void)showTishiLabelWithText:(NSString*)str
{
    self.tishiLabel.text = str;
    [self.tishiLabel sizeToFit];
    self.tishiLabel.center = CGPointMake(KScreenWidth/2, KScreenHeight/2);
    [self performSelector:@selector(hiddenTishiLabel) withObject:nil afterDelay:2];
}
-(void)hiddenTishiLabel
{
    self.tishiLabel.hidden = YES;
}

- (void)disMiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- 检测相机权限
- (BOOL)checkCameraPermission
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 100) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
    
    if (buttonIndex == 1 && alertView.tag == 100) {
        
        [self disMiss];
    }
    
}

-(UIImage *)snapshotSingleView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark --- 时间和日期的作用

- (void)getTimeAndWeakDay
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal fromDate:[NSDate date]];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)components.hour,(long)components.minute];
    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%02ld月%02ld日 %@",components.year,components.month,components.day,[self formatWeekDayWithType:components.weekday]];
    self.locationlabel.text = [YDLoacationManager address];
    
}

-(NSString *)formatWeekDayWithType:(NSInteger)type
{
    NSString *weekStr=nil;
    switch (type) {
        case 2:
        weekStr = @"星期一";
        break;
        case 3:
        weekStr = @"星期二";
        break;
        case 4:
        weekStr = @"星期三";
        break;
        case 5:
        weekStr = @"星期四";
        break;
        case 6:
        weekStr = @"星期五";
        break;
        case 7:
        weekStr = @"星期六";
        break;
        case 1:
        weekStr = @"星期天";
        break;
        default:
        break;
    }
    return weekStr;
}

@end









