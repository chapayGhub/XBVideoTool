//
//  XBVideoCapture.m
//  XBVideoTool
//
//  Created by xxb on 2018/11/30.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBVideoCapture.h"

@interface XBVideoCapture () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t mCaptureQueue;
}
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic,strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput; //
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *mPreviewLayer;
@property (nonatomic,copy) CaptureOutputBlock outputBlock;

@end

@implementation XBVideoCapture

- (id)initWithDisplayView:(UIView *)displayView displayFrame:(CGRect)displayFrame
{
    if (self = [super init])
    {
        _devicePosition = AVCaptureDevicePositionBack;
        _backgroundView = [UIView new];
        [displayView addSubview:_backgroundView];
        _backgroundView.frame = displayFrame;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"XBVideoCapture销毁");
}

- (void)startCaptureWithOutputBlock:(CaptureOutputBlock)outputBlock
{
    _outputBlock = outputBlock;
    if (self.mCaptureSession == nil)
    {
        [self setupCapture];
    }
    [self.mCaptureSession startRunning];
}

- (void)stopCapture
{
    [self pauseCapture];
    [self deSetup];
    [self.backgroundView removeFromSuperview];
}

- (void)pauseCapture
{
    [self.mCaptureSession stopRunning];
}

- (void)resumeCapture
{
    [self.mCaptureSession startRunning];
}

- (void)deSetup
{
    [self.mPreviewLayer removeFromSuperlayer];
    self.mCaptureSession = nil;
    self.mCaptureDeviceInput = nil;
    self.mCaptureDeviceOutput = nil;
}

- (void)changeDevicePosition
{
    [self pauseCapture];
    
    //模糊
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height);
    [self.backgroundView addSubview:effectView];
    
    CGFloat duration = 0.5;
    
    //动画
    NSString *key = @"transition";
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.type = @"oglFlip";
    transition.subtype = kCATransitionFromRight;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.removedOnCompletion = YES;
    [self.mPreviewLayer addAnimation:transition forKey:key];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration - 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self deSetup];
        if (self.devicePosition == AVCaptureDevicePositionFront)
        {
            self.devicePosition = AVCaptureDevicePositionBack;
        }
        else
        {
            self.devicePosition = AVCaptureDevicePositionFront;
        }
        [self startCaptureWithOutputBlock:self.outputBlock];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration * 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [effectView removeFromSuperview];
    });
}

#pragma mark - 创建采集器
- (void)setupCapture
{
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    self.mCaptureSession.sessionPreset = [self getSessionPreset];
    
    mCaptureQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == self.devicePosition)
        {
            inputCamera = device;
        }
    }
    
    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }
    
    self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    [self.mCaptureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:mCaptureQueue];
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
        [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
    }
    AVCaptureConnection *connection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    self.mPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.mCaptureSession];
    [self.mPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.mPreviewLayer setFrame:self.backgroundView.bounds];
    [self.backgroundView.layer addSublayer:self.mPreviewLayer];
}

- (AVCaptureSessionPreset)getSessionPreset
{
    if (_sessionPreset.length)
    {
        return _sessionPreset;
    }
    return AVCaptureSessionPreset1280x720;
}

#pragma mark - 代理方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_outputBlock)
    {
        _outputBlock(captureOutput,sampleBuffer,connection);
    }
}
@end
