//
//  MOCashAmountCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOCashAmountCell.h"

@implementation MOCashAmountCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 14.0, *)) {
            self.backgroundConfiguration = [UIBackgroundConfiguration clearConfiguration];
        }
        [self addSubviews];
    }
    
    return self;
}

-(void)addSubviews {
    
    self.contentView.backgroundColor = ClearColor;
//    [self.bgView cornerRadius:QYCornerRadiusAll radius:10];
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
    }];
    
    [self.bgView addSubview:self.amountLabel];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.centerY.equalTo(self.bgView.mas_centerY);
    }];
}

-(void)configNormalSateCellWithModel:(MOCateOptionItem *)model {
    
    self.bgView.backgroundColor = WhiteColor;
    [self.bgView cornerRadius:QYCornerRadiusAll radius:10 borderWidth:4 borderColor:ColorF2F2F2];
    [self.bgView setNeedsLayout];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"￥" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(12),NSForegroundColorAttributeName: ColorAFAFAF}];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:model.value?:@"" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(24),NSForegroundColorAttributeName: ColorAFAFAF}];
    [string appendAttributedString:string1];
    self.amountLabel.attributedText = string;

}

-(void)configSelectedSateCellWithModel:(MOCateOptionItem *)model {
    
    
    self.bgView.backgroundColor = [Color9A1E2E colorWithAlphaComponent:0.05];
    [self.bgView cornerRadius:QYCornerRadiusAll radius:10 borderWidth:4 borderColor:ColorE24E66];
    [self.bgView setNeedsLayout];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"￥" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(12),NSForegroundColorAttributeName: ColorE24E66}];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:model.value?:@"" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(24),NSForegroundColorAttributeName: ColorE24E66}];
    [string appendAttributedString:string1];
    self.amountLabel.attributedText = string;
}

#pragma mark - setter && getter
-(MOView *)bgView {
    
    if (!_bgView) {
        _bgView = [MOView new];
    }
    return _bgView;
}

-(UILabel *)amountLabel {
    
    if (!_amountLabel) {
        _amountLabel = [UILabel new];
    }
    return _amountLabel;
}
@end
