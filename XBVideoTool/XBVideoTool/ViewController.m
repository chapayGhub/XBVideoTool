//
//  ViewController.m
//  XBVideoTool
//
//  Created by xxb on 2018/11/30.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBVideoCapture.h"
#import "XBVideoEncoder_system.h"
#import "XBDataWriter.h"

#define videoStroePath [NSHomeDirectory() stringByAppendingString:@"/Documents/testVideo.H264"]

@interface ViewController ()
@property (nonatomic,strong) XBVideoCapture *videoCapture;
@property (nonatomic,strong) XBVideoEncoder_system *videoEncoder;
@property (nonatomic,strong) XBDataWriter *dataWriter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoStroePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:videoStroePath error:nil];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak ViewController *weakSelf = self;
    
    self.dataWriter = [XBDataWriter new];
    
    self.videoCapture = [[XBVideoCapture alloc] initWithDisplayView:self.view displayFrame:CGRectMake(20, 70, 360 * 0.9, 640 * 0.9)];
    self.videoCapture.devicePosition = AVCaptureDevicePositionFront;
    
    self.videoEncoder = [[XBVideoEncoder_system alloc] initWidth:720 height:1280 completeBlock:^(NSData *encodedData) {
//        NSLog(@"encoder data");
        [weakSelf.dataWriter writeData:encodedData toPath:videoStroePath];
    }];
    
    [self.videoCapture startCaptureWithOutputBlock:^(AVCaptureOutput *captureOutput, CMSampleBufferRef outputSampleBuffer, AVCaptureConnection *fromConnection) {
//        NSLog(@"get outputSampleBuffer ");
        [weakSelf.videoEncoder encode:outputSampleBuffer];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.videoCapture changeDevicePosition];
}
@end
