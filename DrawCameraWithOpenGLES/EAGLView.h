//
//  EAGLView.h
//  ORB_SLAM2_iOS
//
//  Created by poloby on 2016/12/2.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ESRenderProtocol.h"

@interface EAGLView : UIView

@property (nonatomic, strong) id<ESRenderProtocol> renderder;

@end
