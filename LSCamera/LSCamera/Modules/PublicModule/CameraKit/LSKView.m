//
//  LSKView.m
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "LSKView.h"

@interface LSKView ()<UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *_panGesture;
    BOOL _panGestureDidBeConfirmed;//是否正在识别滑动手势
    
    BOOL _shouldUpdateFilter;//滑动放手的时候是否应该更新滤镜
    CADisplayLink *_switchDisplayLink;
    LSKCameraPanDirection _panDirection;//滑动的方向
    float _panPercent;//滑动的相对百分比
    
    UIPinchGestureRecognizer *_pitchGesture;//缩放手势
}

@end

@implementation LSKView

#pragma mark - lifeCycle


#pragma mark - Init Method

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configGesture];
    }
    return self;
}

- (void)configGesture
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanInDisplayView:)];
    _panGesture.delegate = self;
    _panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_panGesture];
    
    _pitchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPitchInDisplayView:)];
    _pitchGesture.delegate = self;
    [self addGestureRecognizer:_pitchGesture];
    
    self.userInteractionEnabled = YES;
    
    _enablePitchGesture = YES;
    _enableLeftRightPanGesture = YES;
    _enableTopBottomPanGesture = YES;
}


#pragma mark - Action Method

- (void)didPitchInDisplayView:(UIPinchGestureRecognizer *)pitch {
    static CGFloat beginFactor;
    switch (pitch.state) {
        case UIGestureRecognizerStateBegan: {
            beginFactor = _videoZoomFactor;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            self.videoZoomFactor = pitch.scale * beginFactor;
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            self.videoZoomFactor = pitch.scale * beginFactor;
        }
            
        default:
            break;
    }
}

// 滑动手势处理
- (void)didPanInDisplayView:(UIPanGestureRecognizer *)pan {
    
    static CGPoint startPoint;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            startPoint = [pan locationInView:pan.view]; /// 记录开始触碰屏幕的CGPoint
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [pan locationInView:pan.view]; /// 记录移动中的当前CGPoint
            float x = currentPoint.x - startPoint.x; /// 横向的偏差值
            float y = currentPoint.y - startPoint.y; /// 纵向的偏差值
            /// 都是以宽度来计算移动手势的偏移量
            float standardX = x / [UIScreen mainScreen].bounds.size.width;
            float standardY = y / [UIScreen mainScreen].bounds.size.width;
            
            if (!_panGestureDidBeConfirmed) {
                _panGestureDidBeConfirmed = YES;
                
                /// 左右滑动手势和上下切换手势至少有一个没有禁止掉,如果两个都禁止掉不会走此方法
                if (!_enableLeftRightPanGesture) { ///禁止掉了左右滑动手势
                    if (y < 0) {
                        _panDirection = LSKCameraPanDirectionBottomToTop;
                    } else {
                        _panDirection = LSKCameraPanDirectionTopToBottom;
                    }
                } else if (!_enableTopBottomPanGesture) { ///禁止掉了上下滑动手势
                    if (x < 0) {
                        _panDirection = LSKCameraPanDirectionRightToLeft;
                    } else {
                        _panDirection = LSKCameraPanDirectionLeftToRight;
                    }
                } else { /// 都没有禁止
                    float fabsX = fabs(x);
                    float fabsY = fabs(y);
                    if (fabsX > fabsY) { /// 左滑或者右滑
                        if (x < 0) {
                            _panDirection = LSKCameraPanDirectionRightToLeft;
                        } else {
                            _panDirection = LSKCameraPanDirectionLeftToRight;
                        }
                    } else {//上滑或者下滑
                        if (y < 0) {
                            _panDirection = LSKCameraPanDirectionBottomToTop;
                        } else {
                            _panDirection = LSKCameraPanDirectionTopToBottom;
                        }
                    }
                }
                
                /// 返回手势代理开始的回调
                if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewBeginPanWithDirection:)]) {
                    [self.gestureDelegate LSKViewBeginPanWithDirection:_panDirection];
                }
            }
            
            float standard;
            
            if (_panDirection == LSKCameraPanDirectionRightToLeft) {
                standard = -standardX;
            } else if (_panDirection == LSKCameraPanDirectionLeftToRight) {
                standard = standardX;
            } else if (_panDirection == LSKCameraPanDirectionBottomToTop) {
                standard = -standardY;
            } else {
                standard = standardY;
            }
            
            _panPercent = MIN(standard, 1.0);
            /// 返回手势代理滑动中的百分比的回调
            if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewChangedPanWithDirection:percent:)]) {
                [self.gestureDelegate LSKViewChangedPanWithDirection:_panDirection percent:_panPercent];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [pan velocityInView:pan.view];
            
            if ((_panDirection == LSKCameraPanDirectionRightToLeft    && velocity.x < -400)
                || (_panDirection == LSKCameraPanDirectionLeftToRight && velocity.x > 400)
                || (_panDirection == LSKCameraPanDirectionBottomToTop && velocity.y < -400)
                || (_panDirection == LSKCameraPanDirectionTopToBottom && velocity.y > 400)) {
                _shouldUpdateFilter = YES;
            }else {
                NSLog(@"====??? ----%f",velocity.x);
            }
            
            if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewDidEndDraggingPanWithDirection:)]) {
                [self.gestureDelegate LSKViewDidEndDraggingPanWithDirection:_panDirection];
            }
            
            /// 划动大于50%松手了
            if (_panPercent > 0.5) {
                _shouldUpdateFilter = YES;
            }
            
            if (_panPercent > 0.05) { /// 做个动画
                [self stopSwitchFilterAnimation];
                _switchDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startSwitchFilterAniamtion)];
                _switchDisplayLink.frameInterval = 2;
                [_switchDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            } else {
                _panPercent = 0.0;
                if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewBackPanWithDirection:)]) {
                    [self.gestureDelegate LSKViewBackPanWithDirection:_panDirection];
                }

            }
            _panGestureDidBeConfirmed = NO;
        }
        default:
            break;
    }
}

/// 滑动放手后开始做动画
- (void)startSwitchFilterAniamtion {
    self.userInteractionEnabled = NO;
    
    if (_shouldUpdateFilter) { /// 需要更新滤镜
        _panPercent += 0.1;
        _panPercent = LSKClamp(_panPercent, 0.0, 1.0);
        if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewDeceleratingPanWithDirection:percent:)]) {
            [self.gestureDelegate LSKViewDeceleratingPanWithDirection:_panDirection percent:_panPercent];
        }
        
        if (_panPercent >= 1.0) {
            _panPercent = 1.0;
            [self stopSwitchFilterAnimation];
            _shouldUpdateFilter = NO;
            if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewFinishPanWithDirection:)]) {
                [self.gestureDelegate LSKViewFinishPanWithDirection:_panDirection];
            }
            self.userInteractionEnabled = YES;
        }
        
    } else { /// 不需要更新滤镜 回退到原来
        _panPercent -= 0.1;
        _panPercent = LSKClamp(_panPercent, 0.0, 1.0);
        
        if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewDeceleratingPanWithDirection:percent:)]) {
            [self.gestureDelegate LSKViewDeceleratingPanWithDirection:_panDirection percent:_panPercent];
        }
        
        if (_panPercent <= 0.0) {
            _panPercent = 0.0;
            [self stopSwitchFilterAnimation];
            if (self.gestureDelegate && [self.gestureDelegate respondsToSelector:@selector(LSKViewBackPanWithDirection:)]) {
                [self.gestureDelegate LSKViewBackPanWithDirection:_panDirection];
            }
            self.userInteractionEnabled = YES;
        }
    }
}

/// 滑动完毕停止做动画
- (void)stopSwitchFilterAnimation {
    if (_switchDisplayLink) {
        [_switchDisplayLink invalidate];
    }
}


#pragma mark - 手势 Setter && Getter

/// 左右滑动手势
- (void)setEnableLeftRightPanGesture:(BOOL)enableLeftRightPanGesture {
    _enableLeftRightPanGesture = enableLeftRightPanGesture;
    _panGesture.enabled = _enableTopBottomPanGesture || _enableLeftRightPanGesture;
}

/// 上下滑动手势
- (void)setEnableTopBottomPanGesture:(BOOL)enableTopBottomPanGesture {
    _enableTopBottomPanGesture = enableTopBottomPanGesture;
    _panGesture.enabled = _enableTopBottomPanGesture || _enableLeftRightPanGesture;
}

/// 缩放手势
- (void)setEnablePitchGesture:(BOOL)enablePitchGesture {
    _enablePitchGesture = enablePitchGesture;
    _pitchGesture.enabled = _enablePitchGesture;
}


#pragma mark - UIGestureRecognizerDelegate

/// 取消多指触发
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}


#pragma mark - Delegates & Notifications


#pragma mark - Privacy Method


#pragma mark - Setter&Getter


@end
