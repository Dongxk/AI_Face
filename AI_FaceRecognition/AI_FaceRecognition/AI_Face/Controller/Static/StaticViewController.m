//
//  StaticViewController.m
//  AI_FaceRecognition
//
//  Created by 晓坤 on 2018/8/9.
//  Copyright © 2018年 Dongxk. All rights reserved.
//

#import "StaticViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TZImagePickerController.h"


@interface StaticViewController ()<UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureStillImageOutput *ImageOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIView *focusView;


@end


@implementation StaticViewController{
    
    BOOL isflashOn;
    BOOL isExit;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"刷脸";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openAlbum)];
    isExit = YES;
    [self initCamera];
    [self initUI];
}

- (void)openAlbum{
    
    [self pushTZImagePickerController];
}

#pragma mark ----  从相册中选择图片
- (void)pushTZImagePickerController{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.statusBarStyle = UIStatusBarStyleDefault;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        UIImage *albumImage = photos.firstObject;

        [self photoImageVlaue:albumImage];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)initCamera{
    self.view.backgroundColor = [UIColor whiteColor];
  
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    if ([self.device lockForConfiguration:nil]) {
    
        if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
            [self.device setFlashMode:AVCaptureFlashModeOff];
            isflashOn = NO;
        }
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [self.device unlockForConfiguration];
    }
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.ImageOutput]) {
        [self.session addOutput:self.ImageOutput];
    }

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, ScreenSizeWidth, ScreenSizeHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    
    //    self.previewLayer.frame =  CGRectMake((self.view.layer.bounds.size.width - 250) / 2, (self.view.layer.bounds.size.height - 250) / 2, 250, 250);
    //    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    self.previewLayer.cornerRadius = 250 / 2.0f;
    
    [self.session startRunning];
}

- (void)initUI{
    
    UIColor *color = [UIColor blueColor];
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, NavBarHeight, 80, 80)];
    self.focusView.layer.borderWidth = 1.0;
    self.focusView.layer.borderColor = color.CGColor;
    self.focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.focusView];
    self.focusView.hidden = YES;
    
    
    
    CGFloat bottomH = 100;
    CGFloat Y = 30;
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.frame = CGRectMake(0, ScreenSizeHeight - bottomH, ScreenSizeWidth, bottomH);
    [self.view addSubview:bottomView];
    
    self.photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photoBtn.frame = CGRectMake(ScreenSizeWidth / 2 - 30, Y, 60, 60);
    [self.photoBtn setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
    [self.photoBtn setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateSelected];
    self.photoBtn.tag = 1000;
    [self.photoBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.photoBtn];
    
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(15, Y, 60, 60);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancelBtn.tag = 1001;
    [cancelBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelBtn];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(ScreenSizeWidth - 115, Y, 100, 60);
    [cameraBtn setTitle:@"切换摄像头" forState:UIControlStateNormal];
    cameraBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    cameraBtn.tag = 1002;
    [cameraBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cameraBtn];
    
    
    self.flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashBtn.frame = CGRectMake(30, 5, ScreenSizeWidth - 60, 20);
    [self.flashBtn setTitle:@"闪光灯关" forState:UIControlStateNormal];
    self.flashBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.flashBtn setTitleColor:color forState:UIControlStateNormal];
    self.flashBtn.tag = 1003;
    [self.flashBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.flashBtn];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
}

#pragma mark ----  触摸焦点
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        self.focusView.center = point;
        self.focusView.hidden = NO;
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

#pragma mark ----  点击事件处理
- (void)btnClicked:(UIButton *)sender{
    
    if (sender.tag == 1000) {
        //拍照
        [self takePhoto];
    }else if (sender.tag == 1001){
        //取消
        if (isExit == NO) {
            //重新拍照
            [self retakePhoto];
        }else{
            //退出
            if (self.faceRecognitionBlock){
                self.faceRecognitionBlock(NO);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (sender.tag == 1002){
        //切换摄像头
        [self changeCamera];
    }else if (sender.tag == 1003){
        //切换闪光灯
        [self changeFlash];
    }
}

#pragma mark ----  拍照
- (void)takePhoto{
    
    AVCaptureConnection * videoConnection = [self.ImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    [self.ImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *photoImage = [UIImage imageWithData:imgData];
        [self.session stopRunning];
        
        [self photoImageVlaue:photoImage];
    }];
}

#pragma mark ----  取消
- (void)retakePhoto{
    
    isExit = YES;
    [self.photoImageView removeFromSuperview];
    [self.session startRunning];
}

#pragma mark ----  切换摄像头
- (void)changeCamera{
    
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }else{
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
            }else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

#pragma mark ----  闪光灯切换
- (void)changeFlash{
    
    if ([_device lockForConfiguration:nil]) {
        if (isflashOn) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
                isflashOn = NO;
                [self.flashBtn setTitle:@"闪光灯关" forState:UIControlStateNormal];
            }
        }else{
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
                isflashOn = YES;
                [self.flashBtn setTitle:@"闪光灯开" forState:UIControlStateNormal];
            }
        }
        [_device unlockForConfiguration];
    }
}


//获取数据源 显示在自定义的相机上
- (void)photoImageVlaue:(UIImage *)photoImage{
    
    isExit = NO;
    self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, NavBarHeight, ScreenSizeWidth, ScreenSizeHeight - NavBarHeight - 100)];
    self.photoImageView.layer.masksToBounds = YES;
    [self.view insertSubview:_photoImageView belowSubview:self.photoBtn];
    self.photoImageView.image = photoImage;
   
    WeakSelf(self);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [weakself faceRecognitionWithImage:photoImage];
    });
}

#pragma mark ----  人脸识别 ：获取静态图片，识别人脸
- (void)faceRecognitionWithImage:(UIImage *)photoImage {

    NSDictionary *imageOptions =  [NSDictionary dictionaryWithObject:@(5) forKey:CIDetectorImageOrientation];
    CIImage *personciImage = [CIImage imageWithCGImage:photoImage.CGImage];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *faceDetector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    NSArray *features = [faceDetector featuresInImage:personciImage options:imageOptions];
    
    if (features.count > 0) {
        [self uploadPhoto:photoImage];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"识别人脸失败" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self retakePhoto];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark ----  上传到服务器
- (void)uploadPhoto:(UIImage *)photoImage{

    //上传服务器成功后存到本地
    [self savePhotoInfoWithImage:photoImage];
}

#pragma mark ----  保存到本地
- (void)savePhotoInfoWithImage:(UIImage *)image{
    
    //将图片转成base64
    NSData *sourceData = UIImageJPEGRepresentation(image, 1);
    NSString *sourceImageStr = [sourceData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if (sourceImageStr.length == 0) {
        return;
    }

    if (self.faceRecognitionBlock) {
        self.faceRecognitionBlock(YES);
    }
    //存到本地
    [[NSUserDefaults standardUserDefaults] setObject:sourceImageStr forKey:@"AIfacePhoto"];
    
    [self.navigationController popViewControllerAnimated:YES];
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
