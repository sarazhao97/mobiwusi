//
//  MODataTopCardView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MODataTopCardView.h"

@implementation MODataTopCardView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    
    [self addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.largeImageView];
    [self.largeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).offset(12);
        make.right.equalTo(self.mas_right).offset(-17);
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(self.mas_top).offset(13);
    }];
    
    
    [self addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
    
    
    [self addSubview:self.bottomBtn];
    [self.bottomBtn cornerRadius:QYCornerRadiusAll radius:100];
    [self.bottomBtn addTarget:self action:@selector(bottomBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(15);
        make.bottom.equalTo(self.mas_bottom).offset(-11);
        make.width.equalTo(@(65));
        make.height.equalTo(@(26));
    }];
    
}

-(void)bottomBtnClick {
    
    if (self.didBottomBtnClick) {
        self.didBottomBtnClick();
    }
}


#pragma mark - setter && getter
- (UIImageView *)bgImageView {
    
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
    }
    
    return _bgImageView;
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:WhiteColor font:MOPingFangSCMediumFont(14)];
    }
    
    return _titleLabel;
}


-(UILabel *)subTitleLabel {
    
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel labelWithText:@"" textColor:[WhiteColor colorWithAlphaComponent:0.42] font:MOPingFangSCMediumFont(11)];
    }
    
    return _subTitleLabel;
    
}

-(UIImageView *)largeImageView {
    
    if (!_largeImageView) {
        _largeImageView = [UIImageView new];
    }
    
    return _largeImageView;
}

-(MOButton *)bottomBtn {
    
    
    if (!_bottomBtn) {
        _bottomBtn = [MOButton new];
        [_bottomBtn setTitle:@"" titleColor:WhiteColor bgColor:BlackColor font:MOPingFangSCBoldFont(10)];
    }
    
    return _bottomBtn;
    
}
@end
