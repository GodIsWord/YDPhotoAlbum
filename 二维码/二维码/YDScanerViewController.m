//
//  YDScanerViewController.m
//  二维码
//
//  Created by yide zhang on 2018/10/14.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "YDScanerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YDScanWebViewController.h"
#import "UIView+XBFrame.h"
#import "XBWeakProxy.h"
#import <AudioToolbox/AudioToolbox.h>

@interface YDScanerViewController ()<AVCaptureMetadataOutputObjectsDelegate,CALayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong) UIImageView *scanLine;
@property(nonatomic,strong) UIImageView *scanView;
@property(nonatomic,strong) UILabel *resultLabel;

@property(nonatomic,strong) CALayer *maskLayer;

@property(nonatomic, strong) AVCaptureDevice *device;

@property(nonatomic, strong)  AVCaptureDeviceInput *input;

@property(nonatomic, strong)  AVCaptureMetadataOutput *output;

@property(nonatomic, strong) AVCaptureSession *session;

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property(nonatomic,strong) UIImagePickerController *picker;

@property(nonatomic,strong) NSTimer *scanTimer;


@end

@implementation YDScanerViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.scanTimer invalidate];
    self.scanTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubb];
    [self initPickture];
    [self addButton];
    [self initBackButton];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startSaomiao];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopSaomiao];
}
-(void)scanLineMove
{
    self.scanLine.xb_y += 1;
    if (self.scanLine.xb_y >= self.scanView.xb_bottom) {
        self.scanLine.xb_y = self.scanView.xb_y;
    }
}
-(void)addButton{
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHight = self.view.bounds.size.height;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 10, 50, 50);
    [btn setTitle:@"相册" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, screenHight-180, screenWidth-20, 80)];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    self.resultLabel = label;
}
-(void)btnAction{
    [self presentViewController:self.picker animated:YES completion:nil];
}

-(void)initBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame= CGRectMake(10, 0, 25, 25);
    [btn addTarget:self action:@selector(btnClickBack) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[[UIImage imageNamed:@"ydhoto_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
}
-(void)btnClickBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void)initSubb{
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted) {
                //配置扫描view
            } else {
                NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
                [alertView show];
            }
            
        });
    }];
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHight = self.view.bounds.size.height;
    
    self.scanView = [[UIImageView alloc] initWithFrame:CGRectMake(0.2*screenWidth, 0.3*screenHight, 0.6*screenWidth, 0.6*screenWidth)];
    self.scanView.image = [UIImage imageNamed:@"scan_circle@2x"];
    [self.view addSubview:self.scanView];
    self.scanView.center = self.view.center;
    
    self.scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.scanView.xb_x, self.scanView.xb_y, self.scanView.xb_width, 1)];
    self.scanLine.image = [UIImage imageNamed:@"scan_line@2x"];
    [self.view addSubview:self.scanLine];
    
    
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    self.output = output;
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    
    NSMutableArray *a = [[NSMutableArray alloc] init];
    
    if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        
        [a addObject:AVMetadataObjectTypeQRCode];
        
    }
    
    if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
        
        [a addObject:AVMetadataObjectTypeEAN13Code];
        
    }
    
    if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
        
        [a addObject:AVMetadataObjectTypeEAN8Code];
        
    }
    
    if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
        
        [a addObject:AVMetadataObjectTypeCode128Code];
        
    }
    
    output.metadataObjectTypes=a;
    
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    if ([session canAddInput:self.input]) {
        [session addInput:self.input];
    }
    
    if ([session canAddOutput:self.output]) {
        [session addOutput:self.output];
    }
    
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    
    maskLayer.delegate = self;
    [self.view.layer insertSublayer:maskLayer above:layer];
    //让代理方法调用 将周围的蒙版颜色加深
    [maskLayer setNeedsDisplay];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock: ^(NSNotification *_Nonnull note) {
        
        weakSelf.output.rectOfInterest = [weakSelf.layer metadataOutputRectOfInterestForRect:self.scanView.frame];
        
    }];
    
    self.session = session;
    self.layer = layer;
    self.maskLayer = maskLayer;
    
    [self startSaomiao];
}

-(void)startSaomiao
{
    [self.session startRunning];
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:[XBWeakProxy proxyWithTarget:self] selector:@selector(scanLineMove) userInfo:nil repeats:YES];
    self.scanLine.hidden = NO;
    self.scanLine.xb_y = self.scanView.xb_y;
}
-(void)stopSaomiao
{
    [self.session stopRunning];
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    self.scanLine.hidden = YES;
}

/**
 *   蒙版中间一块要空出来
 */

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    
    if (layer == self.maskLayer) {
        
        UIGraphicsBeginImageContextWithOptions(self.maskLayer.frame.size, NO, 1.0);
        
        //蒙版新颜色
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8].CGColor);
        
        CGContextFillRect(ctx, self.maskLayer.frame);
        
        //转换坐标
        CGRect scanFrame = [self.view convertRect:self.scanView.frame fromView:self.scanView.superview];
        
        //空出中间一块
        CGContextClearRect(ctx, scanFrame);
    }
}


/**
 *  如果扫描到了二维码 回调该代理方法
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if(metadataObjects.count > 0){
        
        
        id lastObject = [metadataObjects lastObject];
        if ([lastObject isKindOfClass:AVMetadataMachineReadableCodeObject.class]) {
            AVMetadataMachineReadableCodeObject *metadataObject = (AVMetadataMachineReadableCodeObject *)lastObject;
            if (!metadataObject) {
                return;
            }
            
            NSString *result = metadataObject.stringValue;
            
            NSLog(@"result:%@",result);
            
            [self stopSaomiao];
            
            [self scanSuccessPush:result];
            
        }
        
    }
    
    
}


-(void)readPictureToScaner:(UIImage*)image{
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    if (features.count<=0) {
        return;
    }
    CIQRCodeFeature *feature = [features lastObject];
    NSString *scannedResult = feature.messageString;
    NSLog(@"识别结果 %@",scannedResult);
    
    [self scanSuccessPush:scannedResult];
}
-(void)scanSuccessPush:(NSString*)scanResult
{
    self.resultLabel.text = scanResult;
    
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:@"scanSuccess" ofType:@"wav"];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID soundID=9333;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    if (scanResult.length<=0) {
        return;
    }
    YDScanWebViewController *webView = [[YDScanWebViewController alloc] init];
    webView.loadURL = [NSURL URLWithString:scanResult];
    [self.navigationController pushViewController:webView animated:YES];
}

-(UIImage *)resetImage:(UIImage*)image{
    UIImage* bigImage = image;
    float actualHeight = bigImage.size.height;
    float actualWidth = bigImage.size.width;
    float newWidth =0;
    float newHeight =0;
    if(actualWidth > actualHeight) {
        //宽图
        newHeight =256.0f;
        newWidth = actualWidth / actualHeight * newHeight;
    }
    else
    {
        //长图
        newWidth =256.0f;
        newHeight = actualHeight / actualWidth * newWidth;
    }
    CGRect rect =CGRectMake(0.0,0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [bigImage drawInRect:rect];// scales image to rect
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //RETURN
    return image;
}

-(void)initPickture{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    self.picker = picker;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"info:%@",info);
    UIImage *image = [self resetImage:info[UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self readPictureToScaner:image];
    }];
}


@end
