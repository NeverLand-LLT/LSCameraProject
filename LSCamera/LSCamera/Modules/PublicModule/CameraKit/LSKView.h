//
//  LSKView.h
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "GPUImageView.h"
#import "LSKCameraHeader.h"
NS_ASSUME_NONNULL_BEGIN

@protocol LSKViewGestureDelegate <NSObject>

/**
 开始切换手势

 @param direction 切换手势的方向
 */
- (void)LSKViewBeginPanWithDirection:(LSKCameraPanDirection)direction;

/**
 正在切换手势的状态 手指还在屏幕中

 @param direction 手势方向
 @param percent 切换的进度 0~1
 */
- (void)LSKViewChangedPanWithDirection:(LSKCameraPanDirection)direction percent:(float)percent;

/**
 停止拖动，手指放开屏幕的瞬间

 @param direction 手势方向
 */
- (void)LSKViewDidEndDraggingPanWithDirection:(LSKCameraPanDirection)direction;

/**
 停止拖动到完成之间的动画状态

 @param direction 手势方向
 @param percent 进度百分比
 */
- (void)LSKViewDeceleratingPanWithDirection:(LSKCameraPanDirection)direction percent:(float)percent;

/**
 完成切换手势

 @param direction 手势方向
 */
- (void)LSKViewFinishPanWithDirection:(LSKCameraPanDirection)direction;

/**
 手势回退切换到原来的状态

 @param direction 手势方向
 */
- (void)LSKViewBackPanWithDirection:(LSKCameraPanDirection)direction;

@end

@interface LSKView : GPUImageView

@property (nonatomic, weak) id<LSKViewGestureDelegate> gestureDelegate ;

/**
 是否使用左右滑动手势 默认YES
 */
@property (nonatomic, assign) BOOL enableLeftRightPanGesture;

/**
 是否使用上下滑动手势 默认YES
 */
@property (nonatomic, assign) BOOL enableTopBottomPanGesture;

/**
 是否使用双指缩放手势 默认YES
 */
@property (nonatomic, assign) BOOL enablePitchGesture;

/**
 镜头画面缩放系数，displayView自带缩放手势 大于1的值
 */
@property (nonatomic, assign) CGFloat videoZoomFactor;

@end

NS_ASSUME_NONNULL_END
