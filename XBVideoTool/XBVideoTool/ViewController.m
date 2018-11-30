//
//  ViewController.m
//  XBVideoTool
//
//  Created by xxb on 2018/11/30.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBVideoCapture.h"

@interface ViewController ()
@property (nonatomic,strong) XBVideoCapture *videoCapture;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.videoCapture = [[XBVideoCapture alloc] initWithDisplayView:self.view displayFrame:CGRectMake(20, 70, 360 * 0.9, 640 * 0.9)];
    self.videoCapture.devicePosition = AVCaptureDevicePositionFront;
    
    [self.videoCapture startCaptureWithOutputBlock:^(AVCaptureOutput *captureOutput, CMSampleBufferRef outputSampleBuffer, AVCaptureConnection *fromConnection) {
        NSLog(@"get outputSampleBuffer ");
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.videoCapture changeDevicePosition];
}
@end
