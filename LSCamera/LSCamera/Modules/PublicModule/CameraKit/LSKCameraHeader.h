//
//  LSKCameraHeader.h
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#ifndef LSKCameraHeader_h
#define LSKCameraHeader_h


/**
 滑动手势方向

 - LSKCameraPanDirectionLeftToRight: 滑动手势从左到右
 */
typedef NS_ENUM(NSUInteger,LSKCameraPanDirection) {
    LSKCameraPanDirectionLeftToRight = 0,///<从左到右
    LSKCameraPanDirectionRightToLeft = 1,///<从右到左
    LSKCameraPanDirectionTopToBottom = 2,///<从上到下
    LSKCameraPanDirectionBottomToTop = 3 ///<从下到上
};


#pragma mark - Math

static inline double LSKClamp(double x, double min, double max)
{
    return (x < min ? min : (x > max ? max : x));
}


#endif /* LSKCameraHeader_h */
