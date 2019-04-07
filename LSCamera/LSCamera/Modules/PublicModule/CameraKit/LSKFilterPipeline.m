//
//  LSKFilterPipeline.m
//  LSCamera
//
//  Created by Melody on 2019/4/7.
//  Copyright © 2019 Melody. All rights reserved.
//

#import "LSKFilterPipeline.h"

@interface LSKFilterPipeline ()
{
    NSMutableArray<GPUImageOutput<GPUImageInput> *> *_allFilters;
    GPUImageOutput *_input;
}
@end

@implementation LSKFilterPipeline

#pragma mark - lifeCycle


#pragma mark - Init Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allFilters = [NSMutableArray array];
    }
    return self;
}

/** 根据输入的filters以及input构建LSKFilterPipeLine */
- (instancetype)initWithOrderedFilters:(NSArray *)filters input:(GPUImageOutput *)input
{
    if (self = [self init]) {
        _input = input;
        _allFilters = [NSMutableArray arrayWithArray:filters];
        [self refreshFilters];
    }
    return self;
}


#pragma mark - Action Method

- (void)addFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    if (!filter) return;
    if (![_allFilters containsObject:filter]) {
        [_allFilters addObject:filter];
        [self refreshFilters];
    }
}

- (void)removeFilter:(GPUImageOutput <GPUImageInput> *)filter
{
    if (!filter) return;
    if ([_allFilters containsObject:filter]) {
        [_allFilters removeObject:filter];
        [self refreshFilters];
    }
}

- (void)removeAllFilters
{
    [_allFilters removeAllObjects];
    [self refreshFilters];
}

- (void)replaceAllFilters:(NSArray<GPUImageOutput<GPUImageInput> *> *)filters
{
    if (!filters || filters.count < 1) {
        return;
    }
    _allFilters = [NSMutableArray arrayWithArray:filters];
    [self refreshFilters];
}


#pragma mark - Delegates & Notifications


#pragma mark - Privacy Method

- (void)refreshFilters
{
    id prevFilter = self.input;
    GPUImageOutput<GPUImageInput> *theFilter = nil;
    
    for (int i = 0; i < [self.filters count]; i++) {
        theFilter = [self.filters objectAtIndex:i];
        [prevFilter removeAllTargets];
        [prevFilter addTarget:theFilter];
        prevFilter = theFilter;
    }
    
    [prevFilter removeAllTargets];
    
    if (_allFilters.count > 0) {
        _lastFilter = _allFilters.lastObject;
    } else {
        _lastFilter = nil;
    }
    
}


#pragma mark - Setter&Getter



@end
