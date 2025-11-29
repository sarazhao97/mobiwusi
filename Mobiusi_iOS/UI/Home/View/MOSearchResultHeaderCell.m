//
//  MOSearchResultHeaderCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOSearchResultHeaderCell.h"


@interface MOSearchResultHeaderCell ()



@end

@implementation MOSearchResultHeaderCell

- (void)addSubViews {
    
    self.contentView.backgroundColor = WhiteColor;
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView  mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(7);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.equalTo(@(22));
    }];
    [self.iconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self.contentView addSubview:self.categoryLabel];
    [self.categoryLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.iconImageView.mas_right).offset(1);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    [self.contentView addSubview:self.moreBtn];
    [self.moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBtn  mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.categoryLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@(38));
        make.height.equalTo(@(22));
    }];
}


-(void)moreBtnClick{
    
    if (self.didClickMoreBtn) {
        self.didClickMoreBtn();
    }
    
}


#pragma mark - setter && getter
- (UIImageView *)iconImageView {
    
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        
    }
    
    return _iconImageView;
}

-(UILabel *)categoryLabel {
    
    if (!_categoryLabel) {
        _categoryLabel = [UILabel labelWithText:@"" textColor:Color333333 font:MOPingFangSCMediumFont(13)];
    }
    
    return _categoryLabel;
    
}

- (MOButton *)moreBtn {
    
    if (!_moreBtn) {
        _moreBtn = [MOButton new];
        [_moreBtn setTitle:@"更多" titleColor:Color626262 bgColor:ColorF6F7FA font:MOPingFangSCMediumFont(10)];
        [_moreBtn cornerRadius:QYCornerRadiusAll radius:40];
        [_moreBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    
    return _moreBtn;
    
}


@end
