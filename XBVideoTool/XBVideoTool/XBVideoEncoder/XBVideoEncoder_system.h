//
//  XBVideoEncoder_system.h
//  XBVideoTool
//
//  Created by xxb on 2018/11/30.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

typedef void (^XBVideoEncodeCompleteBlock)(NSData *encodedData);

@interface XBVideoEncoder_system : NSObject
- (instancetype)initWidth:(CGFloat)width height:(CGFloat)height completeBlock:(XBVideoEncodeCompleteBlock)completeBlock;
- (void)encode:(CMSampleBufferRef)sampleBuffer;
- (void)endVideoToolBox;
@end
