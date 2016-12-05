//
//  PJXVideoBuffer.m
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import "PJXVideoBuffer.h"

@interface PJXVideoBuffer ()

@end

@implementation PJXVideoBuffer

#pragma mark - init methods
- (instancetype)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (instancetype)initWithDelegate:(id<ESRenderProtocol>)renderDelegate
{
    if (self = [self init]) {
        _renderder = renderDelegate;
    }
    
    return self;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // 时间戳，以后的文章需要该信息。此处可以忽略
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (CMTIME_IS_VALID(self.preTimeStamp)) {
        self.videoFrameRate = 1.0 / CMTimeGetSeconds(CMTimeSubtract(timestamp, self.preTimeStamp));
    }
    self.preTimeStamp = timestamp;
    
    // 获取图像缓存区内容
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixelBuffer的基址，与下面解锁基址成对
    // CVPixelBufferLockBaseAddress要传两个参数
    // 第一个参数是你要锁定的buffer的基址,第二个参数目前还未定义,直接传'0'即可
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    // 获取图像缓存区的宽高
    int buffWidth = static_cast<int>(CVPixelBufferGetWidth(pixelBuffer));
    int buffHeight = static_cast<int>(CVPixelBufferGetHeight(pixelBuffer));
    // 这一步很重要，将图像缓存区的内容转化为C语言中的unsigned char指针
    // 因为我们在相机设置时，图像格式为BGRA，而后面OpenGL ES的纹理格式为RGBA
    // 这里使用OpenCV转换格式，当然，你也可以不用OpenCV，手动直接交换R和B两个分量即可
    unsigned char* imageData = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    _imgMat = cv::Mat(buffWidth, buffHeight, CV_8UC4, imageData);
    cv::cvtColor(_imgMat, _imgMat, CV_BGRA2RGBA);
    // 解锁pixelBuffer的基址
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    [_renderder render];
}

#pragma mark - getters and setters
- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        // 开始对session进行配置，和[_session commitConfiguration];
        // 两者之间填充的就是配置内容，主要是输入输出配置
        // 也就是AVCaptureDeviceInput和AVCaptureVideoDataOutput
        [_session beginConfiguration];
        // 相机输出的分辨率为640x480
        // 后面会利用该相机输出图像做一些处理，所以分辨率过高或者过低都不好。
        [_session setSessionPreset:AVCaptureSessionPreset640x480];
        
        // 构建视频捕捉设备，AVMediaTypeVideo表示的是视频图像的输入
        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (videoDevice == nil) {
            return nil;
        }
        
        NSError *error = nil;
        
        // 对该捕捉设备进行配置，使用了lockForConfiguration和unlockForConfiguration进行配对
        if ([videoDevice lockForConfiguration:&error]) {
            // 开启自动曝光
            if ([videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            // 开启自动白平衡
            if ([videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            
            // 将焦距设置在最远的位置（接近无限远）以获取最好的color/depth aligment
            [videoDevice setFocusModeLockedWithLensPosition:1.0f completionHandler:nil];
            // 设置帧速率，为了使帧率恒定，将最小和最大帧率设为一样
            // CMTimeMake(1,30)表示帧率为1秒/30帧
            [videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
            [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
            
            [videoDevice unlockForConfiguration];
        }
        
        // 将视频设备作为信息输入来源
        // AVCaptureDeviceInput是AVCaptureInput的子类
        // 特别之处在于，它通过捕获设备来获取多媒体信息
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (error) {
            PJXLog(@"%@", [error localizedDescription]);
        }
        
        // 给session添加了输入源，下面要添加输出部分
        [_session addInput:input];
        
        // 输出部分
        // AVCaptureVideoDataOutput是AVCaptureOutput的子类
        // 特别之处在于，它是专门处理视频图像的输出
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        // 下一帧frame之前如果还没有处理好这帧，就丢弃该帧
        [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
        // 使用BGRA作为图像像素格式
        [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        // 使用AVCaptureVideoDataOutputSampleBufferDelegate代理方法处理每帧图像
        [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        // 给session添加输出源
        [_session addOutput:dataOutput];
        
        // 提交配置
        [_session commitConfiguration];
    }
    
    return _session;
}

@end
