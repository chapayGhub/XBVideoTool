//
//  XBVideoCapture.h
//  XBVideoTool
//
//  Created by xxb on 2018/11/30.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <UIKit/UIKit.h>

typedef void (^CaptureOutputBlock)(AVCaptureOutput *captureOutput, CMSampleBufferRef outputSampleBuffer, AVCaptureConnection *fromConnection);

@interface XBVideoCapture : NSObject

//摄像头位置，默认后置摄像头
@property (nonatomic,assign) AVCaptureDevicePosition devicePosition;

//分辨率，默认720p
@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;

- (id)initWithDisplayView:(UIView *)displayView displayFrame:(CGRect)displayFrame;

- (void)startCaptureWithOutputBlock:(CaptureOutputBlock)outputBlock;

- (void)pauseCapture;

- (void)resumeCapture;

//在XBVideoCapture实例拥有者销毁时调用
- (void)stopCapture;

- (void)changeDevicePosition;

@end
