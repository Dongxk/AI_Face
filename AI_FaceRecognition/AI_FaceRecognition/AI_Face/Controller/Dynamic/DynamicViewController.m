//
//  DynamicViewController.m
//  AI_FaceRecognition
//
//  Created by 晓坤 on 2018/8/3.
//  Copyright © 2018年 Dongxk. All rights reserved.
//

#import "DynamicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+help.h"
#import "ZZDottedLineProgress.h"


@interface DynamicViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) UIButton *exitBtn;
@property (nonatomic, strong) ZZDottedLineProgress *progressView;
@end

@implementation DynamicViewController{
    
    NSInteger faceFlag;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.session startRunning];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    faceFlag = 0;
    [self.view.layer addSublayer:self.previewLayer];
}

- (AVCaptureDevice *)device{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_device lockForConfiguration:nil]) {
            //自动闪光灯
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];
        }
    }
    return _device;
}

- (AVCaptureDeviceInput *)input{
    if (_input == nil) {
        self.device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}

//设置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if (device.position == position ) return device;
    return nil;
}

- (AVCaptureMetadataOutput *)metadataOutput{
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _metadataOutput.rectOfInterest = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    return _metadataOutput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput{
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        //设置像素格式，否则CMSampleBufferRef转换NSImage的时候CGContextRef初始化会出问题
        [_videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    }
    return _videoDataOutput;
}

- (AVCaptureSession *)session{
    if (_session == nil) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要真机运行，才能打开相机哦" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [KeyWindowRootVC presentViewController:alert animated:YES completion:nil];
      
        }else{
            _session = [[AVCaptureSession alloc] init];
            [_session setSessionPreset:AVCaptureSessionPresetHigh];
            if ([_session canAddInput:self.input]) {
                [_session addInput:self.input];
            }
            if ([_session canAddOutput:self.videoDataOutput]) {
                [_session addOutput:self.videoDataOutput];
            }
            if ([_session canAddOutput:self.metadataOutput]) {
                [_session addOutput:self.metadataOutput];
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
            }
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer == nil) {
        
        self.exitBtn = [[UIButton alloc] init];
        [self.exitBtn setFrame:CGRectMake(12, StatusBarHeight, 40, 40)];
        [self.exitBtn addTarget:self action:@selector(exitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.exitBtn setImage:[UIImage imageNamed:@"face_delete"] forState:UIControlStateNormal];
        [self.view addSubview:_exitBtn];

        UILabel *titleLab = [UILabel new];
        [titleLab setFrame:CGRectMake(20, NavBarHeight + 20, ScreenSizeWidth - 40, 30)];
        titleLab.text = @"拿起手机，正对脸";
        titleLab.font = [UIFont boldSystemFontOfSize:20];
        titleLab.textAlignment = 1;
        titleLab.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:titleLab];
        
        
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = CGRectMake((self.view.layer.bounds.size.width - 250) / 2, (self.view.layer.bounds.size.height - 250) / 2, 250, 250);
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.cornerRadius = 250 / 2.0f;
        
        _progressView = [[ZZDottedLineProgress alloc] initWithFrame:CGRectMake(0, 0, 300, 300) startColor:[UIColor redColor] endColor:[UIColor redColor] startAngle:90 strokeWidth:2 strokeLength:20];
        _progressView.center = self.view.center;
        _progressView.roundStyle = YES;
        _progressView.showProgressText = YES;
        _progressView.subdivCount = 90;
        _progressView.textColor = [UIColor clearColor];
        [self.view addSubview:_progressView];
        
    }
    return _previewLayer;
}

- (void)exitBtnClicked{
    [KeyWindowRootVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ----- 实时截取图片
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        AVMetadataFaceObject *faceData = (AVMetadataFaceObject *) [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        
        if (faceData && faceFlag == 0) {
            faceFlag = 1;
        }
    }
}

#pragma mark - 人脸识别成功 ----- 获取动态识别活体人脸
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    if (faceFlag == 1) {
        faceFlag = -99;
        UIImage *constantImage = [self imageFromSampleBuffer:sampleBuffer];
        if (constantImage != nil) {
            [self faceRecognition:constantImage];
        }
    }
}


- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(quartzImage);
    return (image);
}

//接口判断人脸登录
- (void)faceRecognition:(UIImage *)image{
    
    //请求自己接口判断
    NSLog(@"人脸识别成功。。。。");
    
//    CGFloat progress = (CGFloat)bytesRead / totalBytesRead;
    _progressView.progress = 1;
    
    WeakSelf(self);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
         [weakself.navigationController popViewControllerAnimated:YES];
    });
    
   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
