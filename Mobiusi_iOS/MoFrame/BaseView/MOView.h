//
//  MOView.h
//  YuYun
//
//  Created by x11 on 2023/8/17.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOView : UIView

- (CGFloat)topInsert;

- (CGFloat)leftInsert;

- (CGFloat)bottomInsert;

- (CGFloat)rightInsert;

- (CGFloat)horGap;

- (CGFloat)verGap;


- (void)initializeWithFrame:(CGRect)frame;

- (void)addSubViewsInFrame:(CGRect)frame;


- (void)setEnlargeEdge:(CGFloat)size;

- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;


- (void)relayoutFrameOfSubViews;

@end
