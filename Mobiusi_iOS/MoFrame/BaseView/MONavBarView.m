//
//  MONavBarView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MONavBarView.h"

@implementation MONavBarView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(44));
        make.top.equalTo(self.mas_top).offset(STATUS_BAR_Height_CODE);
    }];
    
    [self.contentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_w.png"]];
    [self.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [self.contentView addSubview:self.rightItemsView];
    [self.rightItemsView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right);
        make.right.equalTo(self.contentView.mas_right).offset(-11);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
}

-(void)customStatusBarheight:(CGFloat)newHeight{
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(44));
        make.top.equalTo(self.mas_top).offset(newHeight);
    }];
}



-(void)goBack{
    
    if (self.gobackDidClick) {
        self.gobackDidClick();
    }
}


-(MOButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [MOButton new];
    }
    
    return _backBtn;
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCBoldFont(18)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (MOView *)contentView {
    if (!_contentView) {
        _contentView = [MOView new];
        _contentView.backgroundColor = ClearColor;
    }
    return _contentView;
}

-(UIStackView *)rightItemsView{
    
    
    if (!_rightItemsView) {
        _rightItemsView = [[UIStackView alloc] init];
        _rightItemsView.axis = UILayoutConstraintAxisHorizontal; // 水平排列
        _rightItemsView.spacing = 10; // 子视图间距
        _rightItemsView.alignment = UIStackViewAlignmentCenter; // 对齐方式
        _rightItemsView.distribution = UIStackViewDistributionFillEqually;
//        _rightItemsView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _rightItemsView;
}
@end
