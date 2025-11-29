//
//  MOTableViewCell.h
//  YuYun
//
//  Created by x11 on 2023/9/18.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIView *topLine;

- (void)initialize;

- (void)addSubViews;

- (CGFloat)topInsert;

- (CGFloat)leftInsert;

- (CGFloat)bottomInsert;

- (CGFloat)rightInsert;

- (CGFloat)horGap;

- (CGFloat)verGap;

@end
