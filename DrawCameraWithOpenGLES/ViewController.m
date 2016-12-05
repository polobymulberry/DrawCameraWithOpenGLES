//
//  ViewController.m
//  DrawCameraWithOpenGLES
//
//  Created by poloby on 2016/12/5.
//  Copyright © 2016年 polobymulberry. All rights reserved.
//

#import "ViewController.h"
#import "EAGLView.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLView* glView;

@end

@implementation ViewController

#pragma mark - life cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.glView];
}

#pragma mark - getters and setters
- (EAGLView *)glView
{
    if (_glView == nil) {
        _glView = [[EAGLView alloc] initWithFrame:CGRectMake(0, 0, PJXDeviceWidth, PJXDeviceHeight)];
    }
    
    return _glView;
}

@end
