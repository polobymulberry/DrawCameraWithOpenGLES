//
//  ESRenderProtocol.h
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderProtocol <NSObject>

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end
