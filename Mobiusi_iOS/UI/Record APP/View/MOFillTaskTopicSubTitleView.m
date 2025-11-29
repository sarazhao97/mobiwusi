//
//  MOFillTaskTopicSubTitleView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import "MOFillTaskTopicSubTitleView.h"

@implementation MOFillTaskTopicSubTitleView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(21));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-16);
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.titleLabel.mas_right).offset(3);
    }];
    [self.priceLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
}


-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:Color626262 font:MOPingFangSCMediumFont(10)];
    }
    
    return _titleLabel;
}

-(UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
    }
    
    return _priceLabel;
}
@end
