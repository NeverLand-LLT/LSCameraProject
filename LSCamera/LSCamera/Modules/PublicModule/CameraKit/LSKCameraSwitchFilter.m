//
//  LSKCameraSwitchFilter.m
//  LSCamera
//
//  Created by Melody on 2019/4/5.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "LSKCameraSwitchFilter.h"

#ifndef SHADER_STRING
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)
#endif

NSString *const kCameraSwitchVertextShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 inputTextureCoordinate;
 attribute vec2 inputTextureCoordinate2;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 void main()
{
    textureCoordinate = inputTextureCoordinate;
    textureCoordinate2 = inputTextureCoordinate2;
    
    gl_Position = position;
}
 
 );

NSString *const kCameraSwitchFragmentShader = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform highp float percent; /// 0.0 ~ 1.0
 uniform lowp int direction;  /// 0: 从左到右 1:从右到左
 
 void main()
{
    mediump vec4 firstTextureColor = texture2D(inputImageTexture, textureCoordinate);
    mediump vec4 secondTextureColor = texture2D(inputImageTexture2, textureCoordinate2);
    
    if (direction == 0) {
        if (textureCoordinate.x < percent) {
            gl_FragColor = secondTextureColor;
        }
        else{
            gl_FragColor = firstTextureColor;
        }
    }
    else if (direction == 1){
        if ((1.0 - textureCoordinate.x) < percent) {
            gl_FragColor = secondTextureColor;
        }
        else{
            gl_FragColor = firstTextureColor;
        }
    }
}
 );

@interface LSKCameraSwitchFilter ()

@end

@implementation LSKCameraSwitchFilter

#pragma mark - lifeCycle


#pragma mark - Init Method

- (instancetype)initWithFilter1:(GPUImageOutput<GPUImageInput> *)filter1 filter2:(GPUImageOutput<GPUImageInput> *)filter2
{
    self = [self init];
    if (self) {
        _filter1 = filter1;
        _filter2 = filter2;
        self.percent = 0.0;
        self.direction = LSKCameraPanDirectionLeftToRight;
        _switching = NO;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithVertexShaderFromString:kCameraSwitchVertextShader fragmentShaderFromString:kCameraSwitchFragmentShader];
}


#pragma mark - GPUImageInput

-(void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex
{
    hasReceivedFirstFrame = YES;
    hasReceivedSecondFrame = YES;
    [_filter1 setInputFramebuffer:newInputFramebuffer atIndex:0];
    [_filter1 setInputSize:[newInputFramebuffer size] atIndex:0];
    
    [_filter2 setInputFramebuffer:newInputFramebuffer atIndex:0];
    [_filter2 setInputSize:[newInputFramebuffer size] atIndex:0];
}

- (void)updateFilter1:(GPUImageOutput<GPUImageInput> *)filter1 filter2:(GPUImageOutput<GPUImageInput> *)filter2
{
    runSynchronouslyOnVideoProcessingQueue(^{
        self->_filter1 = filter1;
        self->_filter2 = filter2;
    });
}


#pragma mark - Rendering

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [_filter1 useNextFrameForImageCapture];
    /// PS: _filter1 _filter2 的 usingNextFrameForImageCapture 依然为0，如果需要调用 newCGImageFromCurrentlyProcessedOutput 要注意
    [_filter1 newFrameReadyAtTime:kCMTimeZero atIndex:0];
    
    firstInputFramebuffer = [_filter1 framebufferForOutput];
    
    if (self.isSwitching) {
        [_filter2 useNextFrameForImageCapture];
        [_filter2 newFrameReadyAtTime:kCMTimeZero atIndex:0];
        secondInputFramebuffer = [_filter2 framebufferForOutput];
        [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation]];
        [self informTargetsAboutNewFrameAtTime:frameTime];
    }else {
        outputFramebuffer = firstInputFramebuffer;
        [self informTargetsAboutNewFrameAtTime:frameTime];
    }
    
}


#pragma mark - Setter&Getter

- (void)setPercent:(float)percent
{
    _percent = percent;
    [self setFloat:_percent forUniformName:@"percent"];
}

- (void)setDirection:(LSKCameraPanDirection)direction
{
    _direction = direction;
    [self setInteger:_direction forUniformName:@"direction"];
}

@end
