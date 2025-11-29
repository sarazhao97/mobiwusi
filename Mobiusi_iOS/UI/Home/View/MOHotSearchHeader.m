//
//  MOHotSearchHeader.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOHotSearchHeader.h"

@interface MOHotSearchHeader ()
@property(nonatomic,strong)UIImageView *iconImageView;
@property(nonatomic,strong)UILabel *titleLable;
@property(nonatomic,strong)MOButton *moreBtn;
@end

@implementation MOHotSearchHeader

- (void)addSubViews {
    
    self.contentView.backgroundColor = WhiteColor;
    
    
    [self.contentView addSubview:self.iconImageView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(14));
        make.centerY.equalTo(self.contentView.mas_centerY);
//        make.width.height.equalTo(@(16));
    }];
    [self.iconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.contentView addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(3);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    [self.contentView addSubview:self.moreBtn];
    [self.moreBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-9);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@(38));
        make.height.equalTo(@(20));
    }];
    self.moreBtn.hidden = YES;
}

#pragma mark - setter && getter
-(UIImageView *)iconImageView {
    
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.image = [UIImage imageNamedNoCache:@"icon_search_hotIcon.png"];
    }
    
    return _iconImageView;
}

-(UILabel *)titleLable {
    
    if (!_titleLable) {
        _titleLable = [UILabel labelWithText:NSLocalizedString(@"热门数据", nil) textColor:BlackColor font:MOPingFangSCFont(20)];
        
    }
    
    return _titleLable;
}

-(MOButton *)moreBtn {
    
    if (!_moreBtn) {
        _moreBtn = [MOButton new];
        [_moreBtn setTitle:@"更多" titleColor:Color626262 bgColor:ColorF6F7FA font:MOPingFangSCHeavyFont(10)];
        [_moreBtn cornerRadius:QYCornerRadiusAll radius:40];
    }
    
    return _moreBtn;
}

@end
