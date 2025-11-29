//
//  MOView.m
//  YuYun
//
//  Created by x11 on 2023/8/17.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import "MOView.h"

static CGFloat const topInsert = 15;
static CGFloat const leftInsert = 15;
static CGFloat const bottomInsert = 15;
static CGFloat const rightInsert = 15;

static CGFloat const horGap = 15;
static CGFloat const verGap = 15;

@interface MOView ()

@property (nonatomic, strong) NSNumber *topEdge;
@property (nonatomic, strong) NSNumber *leftEdge;
@property (nonatomic, strong) NSNumber *rightEdge;
@property (nonatomic, strong) NSNumber *bottomEdge;

@end

@implementation MOView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithFrame:frame];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeWithFrame:self.frame];
    }
    return self;
}

- (void)initializeWithFrame:(CGRect)frame {
    [self addSubViewsInFrame:frame];
}

- (void)addSubViewsInFrame:(CGRect)frame {}

- (CGFloat)topInsert {
    return topInsert;
}

- (CGFloat)leftInsert {
    return leftInsert;
}

- (CGFloat)bottomInsert {
    return bottomInsert;
}

- (CGFloat)rightInsert {
    return rightInsert;
}

- (CGFloat)horGap {
    return horGap;
}

- (CGFloat)verGap {
    return verGap;
}


- (void)setEnlargeEdge:(CGFloat)size {
    _topEdge = @(size);
    _leftEdge = @(size);
    _bottomEdge = @(size);
    _rightEdge = @(size);
}

- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right {
    _topEdge = @(top);
    _leftEdge = @(left);
    _bottomEdge = @(bottom);
    _rightEdge = @(right);
}

- (CGRect)enlargedRect {
    if (_topEdge && _rightEdge && _bottomEdge && _leftEdge) {
        return CGRectMake(self.bounds.origin.x - _leftEdge.floatValue,
                          self.bounds.origin.y - _topEdge.floatValue,
                          self.bounds.size.width + _leftEdge.floatValue + _rightEdge.floatValue,
                          self.bounds.size.height + _topEdge.floatValue + _bottomEdge.floatValue);
    } else {
        return self.bounds;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}

- (void)relayoutFrameOfSubViews {
    // do nothing here
}

@end
