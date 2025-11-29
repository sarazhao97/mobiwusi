//
//  MOTableViewCell.m
//  YuYun
//
//  Created by x11 on 2023/9/18.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import "MOTableViewCell.h"

static CGFloat const topInsert = 15;
static CGFloat const leftInsert = 15;
static CGFloat const bottomInsert = 15;
static CGFloat const rightInsert = 15;

static CGFloat const horGap = 15;
static CGFloat const verGap = 15;

@implementation MOTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 14.0, *)) {
            self.backgroundConfiguration = [UIBackgroundConfiguration clearConfiguration];
        }
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self addSubViews];
}

- (void)addSubViews {
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self addSubview:self.topLine];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(@1);
    }];
}

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

#pragma mark - getter setter

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIView *)topLine {
    if (_topLine == nil) {
        _topLine = [UIView new];
        _topLine.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        _topLine.hidden = YES;
    }
    return _topLine;
}

@end
