//
//  MOButton.m
//  Translate
//
//  Created by x11 on 16/8/24.
//  Copyright © 2016年 QC. All rights reserved.
//

#import "MOButton.h"

@interface MOButton ()

@property (nonatomic, strong) NSNumber *topEdge;
@property (nonatomic, strong) NSNumber *leftEdge;
@property (nonatomic, strong) NSNumber *rightEdge;
@property (nonatomic, strong) NSNumber *bottomEdge;

@end

@implementation MOButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(void)fixAlignmentBUG {
    self.imageAlignment = 4;
    self.titleLabel.textAlignment = NSTextAlignmentNatural;
}

#pragma mark - Adjust

- (void)layoutSubviews{
    [super layoutSubviews];
    
    switch (self.imageAlignment) {
        case MOButtonImageAlignmentLeft:{
            
            CGRect oldTitleFrame = self.titleLabel.frame;
            CGRect oldImageFrame = self.imageView.frame;
            
            self.titleLabel.frame = CGRectMake(oldTitleFrame.origin.x + _titleOffsetX, oldTitleFrame.origin.y + _titleOffsetY, oldTitleFrame.size.width, oldTitleFrame.size.height);
            
            self.imageView.frame = CGRectMake(oldImageFrame.origin.x +_imageOffsetX, oldImageFrame.origin.y + _imageOffsetY, oldImageFrame.size.width, oldImageFrame.size.height);
            
            break;
        }
        case MOButtonImageAlignmentRight:{
            
            CGRect oldTitleFrame = self.titleLabel.frame;
            CGRect oldImageFrame = self.imageView.frame;
            
            self.titleLabel.frame = CGRectMake(oldTitleFrame.origin.x - oldImageFrame.size.width/2 + _titleOffsetX, oldTitleFrame.origin.y + _titleOffsetY, oldTitleFrame.size.width, oldTitleFrame.size.height);
            
            self.imageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + _imageOffsetX, oldImageFrame.origin.y + _imageOffsetY, oldImageFrame.size.width, oldImageFrame.size.height);
            
            break;
        }
        case MOButtonImageAlignmentTop:{
            
            break;
        }
        case MOButtonImageAlignmentBottom:{
            
            break;
        }
        default:
            break;
    }
}

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
