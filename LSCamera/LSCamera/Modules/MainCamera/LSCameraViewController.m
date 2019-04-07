//
//  LSCameraViewController.m
//  LSCamera
//
//  Created by Melody on 2019/4/4.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "LSCameraViewController.h"
#import <GPUImage/GPUImage.h>
#import "LSKCamera.h"
#import "LSKCameraSwitchFilter.h"
@interface LSCameraViewController ()<LSKViewGestureDelegate>
{
    LSKCamera *_camera;
}

/** <# 注释 #> */
@property (nonatomic, strong) LSKCameraSwitchFilter * switchFilter ;

/** <# 注释 #> */
@property (nonatomic, assign) NSUInteger  colorFilterIndex ;

//这里声明两个滤镜是为了手势左右滑的时候进去滤镜效果切换，主要是加到switchFilter中进行使用
@property (nonatomic, strong) GPUImageFilter * currentFilter;
@property (nonatomic, strong) GPUImageFilter * anotherFilter;

@end

@implementation LSCameraViewController


#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCamera];
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_camera startRunning];
}


#pragma mark - Init Method

- (void)setUI
{
    _camera.displayView.gestureDelegate = self;
    [self.view addSubview:_camera.displayView];
}

- (void)setupCamera
{
    _camera = [[LSKCamera alloc] initWithCameraPosition:AVCaptureDevicePositionBack sessionPreset:AVCaptureSessionPresetPhoto cameraSize:CGSizeZero displayFrame:CGRectZero];
    
    GPUImageRGBFilter *rgbFilter = [[GPUImageRGBFilter alloc] init];
    rgbFilter.red = 1.0;
    rgbFilter.green = 1.0;
    rgbFilter.blue = 0.0;
    self.currentFilter = rgbFilter;
    
    GPUImageRGBFilter *greenFilter = [[GPUImageRGBFilter alloc] init];
    greenFilter.red = 0.0;
    greenFilter.green = 1.0;
    greenFilter.blue = 0.0;
    self.anotherFilter = greenFilter;
    
    _switchFilter = [[LSKCameraSwitchFilter alloc] initWithFilter1:rgbFilter filter2:greenFilter];
    
    [_camera addFilter:_switchFilter];
    
}

#pragma mark - Action Method

#pragma mark - Delegates & Notifications

#pragma mark - LSKViewGestureDelegate

- (void)LSKViewBeginPanWithDirection:(LSKCameraPanDirection)direction
{
//    NSLog(@"====>BeginPanWithDirection:%lu",direction);
    //从左到右
    if (direction == LSKCameraPanDirectionLeftToRight) {
        
        NSUInteger preIndex = 0;
        preIndex = self.colorFilterIndex - 1;
        GPUImageFilter *anotherFilter = [self getFilterWithIndex:preIndex];
        self.anotherFilter = anotherFilter;
        [self.switchFilter updateFilter1:self.currentFilter filter2:self.anotherFilter];
        
        self.switchFilter.direction = direction;
        self.switchFilter.switching = YES;
 
    }else if (direction == LSKCameraPanDirectionRightToLeft) {
        NSUInteger preIndex = 0;
        preIndex = self.colorFilterIndex + 1;
        GPUImageFilter *anotherFilter = [self getFilterWithIndex:preIndex];
        self.anotherFilter = anotherFilter;
        [self.switchFilter updateFilter1:self.currentFilter filter2:self.anotherFilter];
        
        self.switchFilter.direction = direction;
        self.switchFilter.switching = YES;
    } else {//上下滑亮度
//        self.startExposureTargetBias = self.camera.exposureTargetBias;//记录开始滑动的时候的亮度
//        [self cameraBeginDraggingDelegate];
    }
    
}

- (void)LSKViewChangedPanWithDirection:(LSKCameraPanDirection)direction percent:(float)percent
{
//    NSLog(@"====>ChangedPanWithDirection:%lu percent:%f",(unsigned long)direction,percent);
    if (direction == LSKCameraPanDirectionLeftToRight || direction == LSKCameraPanDirectionRightToLeft) {
        self.switchFilter.percent = percent;
    }else {

    }
}

/// 放手后做动画效果
- (void)LSKViewDeceleratingPanWithDirection:(LSKCameraPanDirection)direction percent:(float)percent
{
//    NSLog(@"====>DeceleratingPanWithDirection:%lu percent:%f",direction,percent);
    if (direction == LSKCameraPanDirectionLeftToRight || direction == LSKCameraPanDirectionRightToLeft) {
        self.switchFilter.percent = percent;
    }
}

- (void)LSKViewDidEndDraggingPanWithDirection:(LSKCameraPanDirection)direction
{
//    NSLog(@"====>DidEndDraggingPanWithDirection:%lu",direction);
}

- (void)LSKViewFinishPanWithDirection:(LSKCameraPanDirection)direction
{
//    NSLog(@"====>FinishPanWithDirection:%lu",direction);
    if (direction != LSKCameraPanDirectionLeftToRight && direction != LSKCameraPanDirectionRightToLeft) {
        return;
    }

    if (direction == LSKCameraPanDirectionLeftToRight) {
        self.colorFilterIndex -= 1;
    }else {
        self.colorFilterIndex += 1;
    }
    
    GPUImageFilter *currentFilter = [self getFilterWithIndex:self.colorFilterIndex];
    self.currentFilter = currentFilter;
    [self.switchFilter updateFilter1:self.currentFilter filter2:self.anotherFilter];
    
    self.switchFilter.percent = 0.0;
    self.switchFilter.switching = NO;

}

- (void)LSKViewBackPanWithDirection:(LSKCameraPanDirection)direction
{
//    NSLog(@"====>backPanWithDirection:%lu",direction);
    if (direction == LSKCameraPanDirectionLeftToRight || direction == LSKCameraPanDirectionRightToLeft) {
        self.switchFilter.switching = NO;
        self.switchFilter.percent = 0.0;
    }
}

#pragma mark - Privacy Method

- (GPUImageFilter *)getFilterWithIndex:(NSUInteger)index
{
//    if (_colorFilterIndex == index) {
//        return self.currentFilter;
//    }
    GPUImageRGBFilter *colorFilter = nil;
    if (index % 2 == 0) {
        colorFilter = [[GPUImageRGBFilter alloc] init];
        colorFilter.red = 1.0;
        colorFilter.green = 1.0;
        colorFilter.blue = 0.0;
        NSLog(@"=====> yellow");
    }else {
        colorFilter = [[GPUImageRGBFilter alloc] init];
        colorFilter.red = 1.0;
        colorFilter.green = 0.0;
        colorFilter.blue = 0.0;
        NSLog(@"=====> red");
//        colorFilter.red   = arc4random()%255/255.0;
//        colorFilter.green = arc4random()%255/255.0;
//        colorFilter.blue  = arc4random()%255/255.0;
    }
    return colorFilter;
}

#pragma mark - Setter&Getter

- (void)setColorFilterIndex:(NSUInteger )colorFilterIndex
{
    if (colorFilterIndex < 0) {
        colorFilterIndex = 0;
    }
    _colorFilterIndex = colorFilterIndex;
}

@end
