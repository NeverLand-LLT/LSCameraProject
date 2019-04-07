//
//  LSKCamera.h
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>
#import "LSKCameraHeader.h"
#import "LSKView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSKCamera : NSObject

#pragma mark -  初始化属性

/**
 显示View
 */
@property (nonatomic, strong, readonly) LSKView *displayView;

/**
 设置需要显示区域的大小 像素为单位
 */
@property (nonatomic, assign) CGRect displayFrame;

/**
 镜头原始输出的分辨率数值可以设置为AVCaptureSessionPresetPhoto(3:4的实际比例)、AVCaptureSessionPreset1280x720、AVCaptureSessionPreset1920x1080
 要注意和cameraSize搭配使用
 */
@property (nonatomic, copy) AVCaptureSessionPreset sessionPreset;

/**
 实际的镜头渲染尺寸 要注意这个值应该和sessionPreset搭配使用,宽高比例要对，如AVCaptureSessionPresetPhoto是3:4的，而其他值是9:16的尺寸
 sessionPreset设置AVCaptureSessionPresetPhoto比例是3:4的 然后cameraSize可以设置CGSize(640, 852)、CGSize(720, 960)、CGSize(1080, 1440);
 sessionPreset如果是AVCaptureSessionPreset1280x720、cameraSize可设置为CGSize(720, 1280)、4寸机型可以设置CGSize(640, 1136);
 sessionPreset设置AVCaptureSessionPreset1920x1080、cameraSize可设置为CGSize(1080, 1920)  注意低端机型不能设置1920x1080的尺寸
 */
@property (nonatomic, assign) CGSize cameraSize;

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)position
                         sessionPreset:(AVCaptureSessionPreset)sessionPreset
                            cameraSize:(CGSize)cameraSize
                          displayFrame:(CGRect)displayFrame;

- (void)setDiplayViewGestureDelegate:(id<LSKViewGestureDelegate>)gestureDelegate;

#pragma mark - 镜头启动开关

/**
 开始镜头输出
 */
- (void)startRunning;

/**
 停止镜头输出
 */
- (void)stopRunning;

/**
 重启镜头
 */
- (void)restartRunning;

/**
 切换前后镜头
 */
- (void)switchCamera;

/**
 添加滤镜到处理链中
 
 @param filter 要添加滤镜
 */
- (void)addFilter:(GPUImageOutput<GPUImageInput>*)filter;


@end

NS_ASSUME_NONNULL_END
