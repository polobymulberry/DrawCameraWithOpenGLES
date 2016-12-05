//
//  ES1Renderer.m
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import "ES1Renderer.h"
#import "PJXVideoBuffer.h"

@implementation ES1Renderer

#pragma mark - init methods
// 1.构建和设置绘制上下文环境
// 2.生成frame buffer和render buffer并绑定
// 3.生成相机纹理
- (instancetype)init
{
    if (self = [super init]) {
        // 构建OpenGL ES 1.0绘制上下文环境
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        // 设置当前绘制上下文环境为OpenGL ES 1.0
        if (!_context || ![EAGLContext setCurrentContext:_context]) {
            return nil;
        }
        
        // 生成frame buffer和render buffer
        // frame buffer并不是一个真正的buffer，而是用来管理render buffer、depth buffer、stencil buffer
        // render buffer相当于主要是存储像素值的
        // 所以需要glFramebufferRenderbufferOES将render buffer绑定到frame buffer的GL_COLOR_ATTACHMENT0_OES上
        glGenFramebuffersOES(1, &_defaultFrameBuffer);
        glGenRenderbuffersOES(1, &_colorRenderBuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, _defaultFrameBuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderBuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _colorRenderBuffer);
        // 构建一个绘制相机的纹理
        _camTexId = [self genTexWithWidth:640 height:480];
    }
    
    return self;
}

#pragma mark - private methods
// 构建一个宽width高height的纹理对象
- (GLuint)genTexWithWidth:(GLuint)width height:(GLuint)height
{
    GLuint texId;
    // 生成并绑定纹理对象
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);
    // 注意这里纹理的像素格式为GL_RGBA
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    // 各种纹理参数，这里不赘述
    glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_FALSE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    // 解绑纹理对象
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return texId;
}

#pragma mark - ESRenderProtocol
- (void)render
{
    // 设置绘制上下文
    [EAGLContext setCurrentContext:_context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _defaultFrameBuffer);
    
    // 相机纹理坐标
    static GLfloat spriteTexcoords[] = {
        0,0,
        1,0,
        0,1,
        1,1};
    // 相机顶点坐标
    static GLfloat spriteVertices[] = {
        0,0,
        0,640,
        480,0,
        480,640};
    
    // 清除颜色缓存
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    // 视口矩阵
    glViewport(0, 0, _backingWidth, _backingHeight);
    // 投影矩阵
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    // 正投影
    glOrthof(480, 0, _backingHeight*480/_backingWidth, 0, 0, 1); // 852 = 568*480/320
    // 模型视图矩阵
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // OpenGL ES使用的是状态机方式
    // 以下开启的意义是在GPU上分配对应空间
    glEnableClientState(GL_VERTEX_ARRAY); // 开启顶点数组
    glEnableClientState(GL_TEXTURE_COORD_ARRAY); // 开启纹理坐标数组
    glEnable(GL_TEXTURE_2D); // 开启2D纹理
    // 因为spriteVertices、spriteTexcoords、_camTexId还在CPU内存，需要传递给GPU处理
    // 将spriteVertices传递到顶点数组中
    glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
    // 将spriteTexcoords传递到纹理坐标数组中
    glTexCoordPointer(2, GL_FLOAT, 0, spriteTexcoords);
    // 将camTexId纹理对象绑定到2D纹理
    glBindTexture(GL_TEXTURE_2D, _camTexId);
    // 根据videoBuffer获取imgMat（相机图像）
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 640, 480, GL_RGBA, GL_UNSIGNED_BYTE, _videoBuffer.imgMat.data);
    // 绘制纹理
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 解绑2D纹理
    glBindTexture(GL_TEXTURE_2D, 0);
    // 与上面的glEnable*一一对应
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // 将render buffer内容绘制到屏幕上
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // 与init中类似，重新绑定一下而已
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    // 状态检查
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        PJXLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    // 实例化videoBuffer并启动捕获图像任务
    if (_videoBuffer == nil) {
        // 注意PJXVideoBuffer的delegate为ES1Renderer，主要在videoBuffer中执行render函数来绘制相机
        _videoBuffer = [[PJXVideoBuffer alloc] initWithDelegate:self];
        [_videoBuffer.session startRunning];
    }
    
    return YES;
}

@end
