//
//  ES1Renderer.h
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "ESRenderProtocol.h"

@class PJXVideoBuffer;

@interface ES1Renderer : NSObject <ESRenderProtocol>
// OpenGL ES绘制上下文环境
// 只有在在当前线程中设置好了该上下文环境，才能使用OpenGL ES的功能
@property (nonatomic, strong) EAGLContext *context;
// 绘制camera的纹理id
@property (nonatomic, assign) GLuint camTexId;
// render buffer和frame buffer
@property (nonatomic, assign) GLuint defaultFrameBuffer;
@property (nonatomic, assign) GLuint colorRenderBuffer;
// 获取到render buffer的宽高
@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;
// 引用了videoBuffer，主要用于启动捕捉图像的Session以及获取捕捉到的图像
@property (nonatomic, strong) PJXVideoBuffer *videoBuffer;

@end
