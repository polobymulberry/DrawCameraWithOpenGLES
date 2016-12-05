//
//  EAGLView.m
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import "EAGLView.h"
#import "ES1Renderer.h"

@implementation EAGLView

// 默认UIView的layerClass为[CALayer class]
// 重写layerClass为CAEAGLLayer，这样self.layer返回的就不是CALayer
// 而是支持OpenGL ES的CAEAGLLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        // layer默认时透明的，只有设置为不透明才能看见
        eaglLayer.opaque = TRUE;
        // 配置eaglLayer的绘制属性
        // kEAGLDrawablePropertyRetainedBacking不维持上一次绘制内容，也就说每次绘制之前都重置一下之前的绘制内容
        // kEAGLDrawablePropertyColorFormat像素格式为RGBA，注意和相机直接给的BGRA不一致，需要转换
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        // 此处使用OpenGL ES 1.0进行绘制，所以实例化ES1Renderer
        // ES1Renderer表示的是OpenGL ES 1.0绘制环境，后面详解
        if (!_renderder) {
            _renderder = [[ES1Renderer alloc] init];
            
            if (!_renderder) {
                return nil;
            }
        }
    }
    
    return self;
}

#pragma mark - life cycles
- (void)layoutSubviews
{
    // 利用renderer渲染器进行绘制
    [_renderder resizeFromLayer:(CAEAGLLayer *)self.layer];
}

@end
