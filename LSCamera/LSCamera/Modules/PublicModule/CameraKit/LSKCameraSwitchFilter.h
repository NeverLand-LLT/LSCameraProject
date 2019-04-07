//
//  LSKCameraSwitchFilter.h
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"
#import "LSKCameraHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface LSKCameraSwitchFilter : GPUImageTwoInputFilter
{
    GPUImageOutput<GPUImageInput> *_filter1;
    GPUImageOutput<GPUImageInput> *_filter2;
}

/**
 是否正在切换手势
 */
@property (nonatomic, assign, getter=isSwitching) BOOL switching;

/**
 切换滤镜比例，默认是0，只有switching = YES才有效 0~1范围
 */
@property (nonatomic, assign) float percent;

/**
 滑动方向，目前支持只左右滑动的滤镜切换
 */
@property (nonatomic, assign) LSKCameraPanDirection direction;

- (instancetype)initWithFilter1:(GPUImageOutput<GPUImageInput> *)filter1 filter2:(GPUImageOutput<GPUImageInput> *)filter2;

- (void)updateFilter1:(GPUImageOutput<GPUImageInput> *)filter1 filter2:(GPUImageOutput<GPUImageInput> *)filter2;

@end

NS_ASSUME_NONNULL_END
