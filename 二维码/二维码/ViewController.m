//
//  ViewController.m
//  二维码
//
//  Created by yidezhang on 2018/8/22.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,CALayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong) UIView *scanLine;
@property(nonatomic,strong) UIView *scanView;
@property(nonatomic,strong) UILabel *resultLabel;

@property(nonatomic,strong) NSLayoutConstraint *scanViewH;

@property(nonatomic,strong) CALayer *maskLayer;

@property(nonatomic, strong) AVCaptureDevice *device;

@property(nonatomic, strong)  AVCaptureDeviceInput *input;

@property(nonatomic, strong)  AVCaptureMetadataOutput *output;

@property(nonatomic, strong) AVCaptureSession *session;

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property(nonatomic,strong) UIImagePickerController *picker;


@end

@implementation ViewController

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubb];
    [self initPickture];
    [self addButton];
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}

-(void)addButton{
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHight = self.view.bounds.size.height;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 10, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, screenHight-180, screenWidth-20, 80)];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    self.resultLabel = label;
}
-(void)btnAction{
    [self presentViewController:self.picker animated:YES completion:nil];
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
    
    self.scanView = [[UIView alloc] initWithFrame:CGRectMake(0.2*screenWidth, 0.3*screenHight, 0.6*screenWidth, 0.6*screenWidth)];
    [self.view addSubview:self.scanView];
    self.scanView.center = self.view.center;
    
    self.scanLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 5)];
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

    
    
    [session startRunning];
    
    
    self.session = session;
    self.layer = layer;
    self.maskLayer = maskLayer;
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
    
    if(metadataObjects.count > 0 && metadataObjects != nil){
        
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects lastObject];
        
        if (!metadataObject) {
            return;
        }
        
        NSString *result = metadataObject.stringValue;
        
        NSLog(@"result:%@",result);
        self.resultLabel.text = result;
        
        [self.session stopRunning];
        
//        [self.scanLine removeFromSuperview];
        
    }
    
    
}


-(void)redPicture:(UIImage*)image{
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:ciImage];
    if (features.count<=0) {
        return;
    }
    CIQRCodeFeature *feature = [features lastObject];
    NSString *scannedResult = feature.messageString;
    NSLog(@"识别结果 %@",feature);
    
    self.resultLabel.text = scannedResult;
    
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
    [self redPicture:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end







