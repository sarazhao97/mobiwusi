//
//  MOButton.h
//  Translate
//
//  Created by x11 on 16/8/24.
//  Copyright © 2016年 QC. All rights reserved.
//  

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MOButtonImageAlignmentLeft,
    MOButtonImageAlignmentRight,
    MOButtonImageAlignmentTop,
    MOButtonImageAlignmentBottom,
} MOButtonImageAlignment;

@interface MOButton : UIButton

@property (nonatomic, assign) MOButtonImageAlignment imageAlignment;

@property (nonatomic, assign) NSInteger titleOffsetX;
@property (nonatomic, assign) NSInteger titleOffsetY;
@property (nonatomic, assign) NSInteger imageOffsetX;
@property (nonatomic, assign) NSInteger imageOffsetY;

- (void)setEnlargeEdge:(CGFloat)size;

- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
-(void)fixAlignmentBUG;
@end
