//
//  LSKFilterPipeline.h
//  LSCamera
//
//  Created by Melody on 2019/4/7.
//  Copyright © 2019 Melody. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface LSKFilterPipeline : NSObject

@property (nonatomic, strong, readonly) NSMutableArray * filters ;

/** 纹理输出者 会连接filters的第一个filter */
@property (nonatomic, strong, readonly) GPUImageOutput * input ;

/** filters里面最后一个Filter */
@property (nonatomic, strong, readonly) id<GPUImageInput> lastFilter ;

/** 根据输入的filters以及input构建LSKFilterPipeLine */
- (instancetype)initWithOrderedFilters:(NSArray *)filters input:(GPUImageOutput *)input;

- (void)addFilter:(GPUImageOutput<GPUImageInput> *)filter;

- (void)removeFilter:(GPUImageOutput <GPUImageInput> *)filter;

- (void)removeAllFilters;

- (void)replaceAllFilters:(NSArray<GPUImageOutput<GPUImageInput> *> *)filters;

@end

NS_ASSUME_NONNULL_END
