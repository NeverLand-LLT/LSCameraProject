//
//  LSKCamera.m
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "LSKCamera.h"
#import "LSKFilterPipeline.h"
@interface LSKCamera ()<GPUImageVideoCameraDelegate>
{
    GPUImageStillCamera *_camera;
    GPUImageFilter *_emptyFilter;
    GPUImageCropFilter *_cropFilter;
    
    /// tmp
    NSMutableArray *_filters;
}
@end

@implementation LSKCamera

#pragma mark - lifeCycle


#pragma mark - Init Method

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position
                         sessionPreset:(AVCaptureSessionPreset)sessionPreset
                            cameraSize:(CGSize)cameraSize displayFrame:(CGRect)displayFrame
{
    if (!(self = [super init])) return nil;
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    BOOL isIphone4 = screenWidth > 319 && screenWidth < 321 && screenHeight > 479 && screenHeight < 481;
    
    //iPhone4s前置不支持720的尺寸
    if (isIphone4) {
        _sessionPreset = AVCaptureSessionPresetPhoto;
        _cameraSize = CGSizeMake(640, 852);
    } else {
        _sessionPreset = sessionPreset;
        _cameraSize = cameraSize;
    }
    
    /// 初始化镜头
    _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:sessionPreset cameraPosition:position];
    _camera.outputImageOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    _camera.delegate = self;
    
    
    /// 初始化displayView
    _displayView = [[LSKView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [_displayView setBackgroundColorRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    
    /// 滤镜链
    _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    _emptyFilter = [[GPUImageFilter alloc] init];
    
    [_camera addTarget:_emptyFilter];
    [_emptyFilter addTarget:_cropFilter];
    [_cropFilter addTarget:_displayView];
    _filters = [[NSMutableArray alloc] init];
    
    _displayFrame = displayFrame;
    [self updateCameraChainOutputFrame];
    
    return self;
}


#pragma mark - Action Method

- (void)setDiplayViewGestureDelegate:(id<LSKViewGestureDelegate>)gestureDelegate
{
    if (gestureDelegate) {
        self.displayView.gestureDelegate = gestureDelegate;
    }
}

#pragma mark - 镜头启动开关

- (void)startRunning
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self->_camera startCameraCapture];
        self->_camera.enabled = YES;
        self->_camera.delegate = self;
    });
}

- (void)stopRunning
{
    _camera.enabled = NO;
    _camera.delegate = nil;
    [_camera stopCameraCapture];
    
}

- (void)restartRunning
{
    [_camera stopCameraCapture];
    [_camera startCameraCapture];
    _camera.enabled = YES;
    _camera.delegate = self;
}

- (void)switchCamera
{
    _camera.enabled = NO;
    [_camera rotateCamera];
//    self.videoZoomFactor = _videoZoomFactor;//切换镜头需要重新设置放大参数
//    self.maxFrameDuration = _maxFrameDuration;//切换镜头需要重新设置帧率
//    self.minFrameDuration = _minFrameDuration;
    _camera.enabled = YES;
}

- (void)addFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    if (![_filters containsObject:filter]) {
        [_filters addObject:filter];
        [self refreshFilters];
        
        [_camera addTarget:_emptyFilter];
        [_emptyFilter addTarget:_cropFilter];
        [_cropFilter addTarget:filter];
        [filter addTarget:_displayView];
    }
}


#pragma mark - Delegates & Notifications


#pragma mark - GPUImageVideoCameraDelegate

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    
}


#pragma mark - Privacy Method

- (void)updateCameraChainOutputFrame
{
    
    
}

- (void)refreshFilters
{
    [_camera removeAllTargets];
    [_emptyFilter removeAllTargets];
    [_cropFilter removeAllTargets];
    
    [_filters enumerateObjectsUsingBlock:^(GPUImageOutput<GPUImageInput> * _Nonnull filter, NSUInteger idx, BOOL * _Nonnull stop) {
        [filter removeAllTargets];
    }];
}


#pragma mark - Setter&Getter


@end
