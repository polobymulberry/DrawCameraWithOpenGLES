//
//  PJXVideoBuffer.h
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "ESRenderProtocol.h"

#include <opencv2/opencv.hpp>

@interface PJXVideoBuffer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) CMTime preTimeStamp;
@property (nonatomic, assign) CMVideoDimensions videoDimensions;
@property (nonatomic, assign) Float64 videoFrameRate;
@property (nonatomic, assign) CMVideoCodecType videoType;
@property (nonatomic, assign) cv::Mat imgMat;
@property (nonatomic, strong) id<ESRenderProtocol> renderder;

- (instancetype)initWithDelegate:(id<ESRenderProtocol>)renderDelegate;

@end
