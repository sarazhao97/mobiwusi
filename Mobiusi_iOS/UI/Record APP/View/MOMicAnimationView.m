//
//  MOMicAnimationView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/16.
//

#import "MOMicAnimationView.h"

@interface MOMicAnimationView ()

@property (nonatomic, strong) CALayer *animationLayer;

@end

@implementation MOMicAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
    [_animationLayer removeFromSuperlayer];
    _animationLayer = [self micAnimationLayer:size];
    [self.layer addSublayer:_animationLayer];
}

- (void)updateMeters:(CGFloat)progress {
    
    // 保留两位小数 (四舍五入)
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                           decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                           scale:2
                                           raiseOnExactness:NO
                                           raiseOnOverflow:NO
                                           raiseOnUnderflow:NO
                                           raiseOnDivideByZero:YES];
    NSDecimalNumber *n = [[NSDecimalNumber alloc] initWithFloat:progress];
    n = [n decimalNumberByRoundingAccordingToBehavior:roundUp];
    progress = [n floatValue];
    
    [self animationWithMeters:progress];
}

- (void)animationWithMeters:(CGFloat)progress {
    
    CAAnimation * animation = [self _animationWithMeters:progress];
    [_animationLayer addAnimation:animation forKey:@"micAnimation"];
}

- (CALayer *)micAnimationLayer:(CGSize)size {
    
    CALayer * animationLayer = [CALayer layer];
    animationLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    /** 边线layer */
    CALayer *borderLayer = [CALayer layer];
    borderLayer.frame = CGRectMake(0, 0, size.width, size.height);
    borderLayer.borderColor = _borderColor.CGColor;
    borderLayer.borderWidth = 0.5;
    borderLayer.cornerRadius = size.height / 2;
    
    /** 内圈layer */
    CALayer *innercircleLayer = [CALayer layer];
    CGFloat innercircleWidth = size.width - 5;
    CGFloat innercircleHeight = size.height - 5;
    innercircleLayer.frame = CGRectMake(0, 0, innercircleWidth, innercircleHeight);
    innercircleLayer.position = CGPointMake(size.width / 2, size.height / 2);
    innercircleLayer.cornerRadius = innercircleHeight / 2;
    innercircleLayer.backgroundColor = _innercircleColor.CGColor;
    
    [animationLayer addSublayer:borderLayer];
    [animationLayer addSublayer:innercircleLayer];
    
    return animationLayer;
}

- (CAAnimation *)_animationWithMeters:(CGFloat)progress {
    
    double animationDuration = 0.5;
    
    /** 缩放动画 */
    CGFloat mixValue = 3.2;
    CGFloat minValue = 1.0;
    CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(minValue + (mixValue - minValue) * progress);
    scaleAnimation.toValue = @(minValue);
    
    /** 透明度动画 */
    CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@1, @0.9, @0.8, @0.7, @0.6, @0.5, @0.4, @0.3, @0.2, @0.1, @0];
    opacityAnimation.keyTimes = @[@0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1];
    
    /** 组动画 (缩放 + 透明度) */
    CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
    animationGroup.fillMode = kCAFillModeBackwards;
    animationGroup.beginTime = CACurrentMediaTime() + 0.5;
    animationGroup.duration = animationDuration;
    animationGroup.repeatCount = 1;
    animationGroup.timingFunction = defaultCurve;
    animationGroup.animations = @[scaleAnimation];
    
    return animationGroup;
}


@end
