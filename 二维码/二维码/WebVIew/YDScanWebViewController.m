//
//  YDScanWebViewController.m
//  OLinPiKe
//
//  Created by 张义德 on 16/6/21.
//  Copyright © 2016年 alta. All rights reserved.
//

#import "YDScanWebViewController.h"

#import "IMYWebView.h"

#import "UtinityDefine.h"

@interface YDScanWebViewController ()<UIWebViewDelegate,IMYWebViewDelegate>
@property (nonatomic,strong) ArtaWebProgressView *progressBar;//进度条
@property (nonatomic,strong) IMYWebView *webView;
@property (nonatomic,strong) UILabel *labelURl;
@end

@implementation YDScanWebViewController

-(UILabel *)labelURl
{
    if (!_labelURl) {
        _labelURl = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _labelURl.textColor = [UIColor blackColor];
        _labelURl.textAlignment = NSTextAlignmentNatural;
        _labelURl.contentMode = UIViewContentModeTopLeft;
        [self.view addSubview:_labelURl];
    }
    return _labelURl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initBackButton];
    [self createWebView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)initBackButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame= CGRectMake(10, 0, 25, 25);
    [btn addTarget:self action:@selector(btnClickBack) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[[UIImage imageNamed:@"ydhoto_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
}
-(void)btnClickBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)createWebView
{

    if ([self.loadURL.absoluteString containsString:@"http"]) {
        [self createIWKWebView];
    }else{
        self.labelURl.text = self.loadURL.absoluteString;
        [self.labelURl sizeToFit];
    }
    
}
#pragma mark -  WKWebView
-(void)createIWKWebView
{
    
    
    if (IOS8DEVICE) {
        self.webView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    }else{
        self.webView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) usingUIWebView:YES];
    }
    [self.view addSubview:_webView];
    
    self.webView.delegate = self;
    
    if (self.loadType == ArtaWebLoadTypeWebUrl) {
        [_webView loadRequest:[NSURLRequest requestWithURL:self.loadURL]];
    }else if(self.loadType == ArtaWebLoadTypeLoacalH5){
        [_webView loadHTMLString:self.loadHTMLString baseURL:self.loadURL];
    }

    ArtaWebProgressView *progressBar = [[ArtaWebProgressView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 3) progressHeight:3];
    [self.view addSubview:progressBar];
    self.progressBar = progressBar;
}
-(void)webViewDidStartLoad:(IMYWebView *)webView
{
    [self.progressBar webViewDidStartLoadProgressAnimation];
}
-(void)webViewDidFinishLoad:(IMYWebView *)webView
{
    [self.progressBar webViewDidFinishLoadProgressAnimation];
    self.title = webView.title;
}
-(void)webView:(IMYWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.progressBar webViewDidFinishLoadProgressAnimation];
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end


@implementation ArtaWebProgressView

-(instancetype)initWithFrame:(CGRect)frame progressHeight:(float)height
{
    self=  [super initWithFrame:frame];
    if (self) {
        self.animationFinish=YES;
        self.time = 0.3;
        self.progressHeight = height;
        UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, height)];
        view.backgroundColor =[UIColor colorWithHexString:@"#fea1a1"];
        view.tag = 100;
        self.progressView = view;
        [self addSubview:view];
    }
    return self;
}

-(void)webViewDidStartLoadProgressAnimation
{
    self.isWebStartAnmation = YES;
    [self progressAnimation];
}

-(void)webViewDidFinishLoadProgressAnimation
{
    self.isWebEndAnmation = YES;
    [self progressAnimation];
}

-(void)shouldStartLoadWithRequestProgressAnimation
{
    self.yanshi += 1;
    [self progressAnimation];
}

-(void)progressAnimation
{
    if (self.animationFinish) {
        self.animationFinish = NO;
        [UIView animateWithDuration:self.time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            if (self.isWebStartAnmation) {
                CGRect frame = self.progressView.frame;
                frame.size.width = 1 * self.bounds.size.width;
                self.progressView.frame = frame;
            }else if(self.isWebEndAnmation){
                CGRect frame = self.progressView.frame;
                frame.size.width =  self.bounds.size.width;
                self.progressView.frame = frame;
            }else{
                
                CGRect frame = self.progressView.frame;
                if (frame.size.width>=.5* self.bounds.size.width) {
                    frame.size.width = 0.8 * self.bounds.size.width;
                }else{
                    frame.size.width += 0.25 * self.bounds.size.width;
                }
                self.progressView.frame = frame;
            }
        } completion:^(BOOL finished){
            self.animationFinish =YES;
            if (self.isWebStartAnmation) {
                self.isWebStartAnmation = NO;
                [self progressAnimation];
                return ;
            }
            if (self.isWebEndAnmation) {
                self.isWebEndAnmation = NO;
                self.progressView.frame=CGRectMake(0, 0, 0,   self.progressHeight);
                self.time=0.3;
                return ;
            }
            self.time =.2;
            self.yanshi-=1;
            if (self.yanshi<=0) {
                
            }else{
                [self progressAnimation];
            }
        }];
    }
}

@end

