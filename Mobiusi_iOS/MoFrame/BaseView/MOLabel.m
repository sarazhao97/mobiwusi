//
//  MOLabel.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/4.
//

#import "MOLabel.h"
@interface MOLabel ()

@property (nonatomic, strong) NSNumber *topEdge;
@property (nonatomic, strong) NSNumber *leftEdge;
@property (nonatomic, strong) NSNumber *rightEdge;
@property (nonatomic, strong) NSNumber *bottomEdge;

@end

@implementation MOLabel

#pragma mark - Enlarge

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


@end
