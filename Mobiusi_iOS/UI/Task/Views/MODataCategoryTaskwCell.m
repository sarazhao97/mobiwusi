//
//  MODataCategoryTaskwCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MODataCategoryTaskwCell.h"

@interface MODataCategoryTaskwCell ()
@property(nonatomic,strong)CAGradientLayer *gradientLayerLevel1;
@property(nonatomic,strong)CAGradientLayer *gradientLayerLevel2;
@property(nonatomic,strong)CAGradientLayer *gradientLayerLevel3;
@end

@implementation MODataCategoryTaskwCell



-(void)layoutSubviews {
    [super layoutSubviews];
    [self updateBGViewGradientLayer];
}

-(void)updateBGViewGradientLayer {
    
    if (self.gradientLayerLevel1) {
        
        if (self.gradientLayerLevel1.frame.size.width != self.bgContentView.bounds.size.width ||
            self.gradientLayerLevel1.frame.size.height != self.bgContentView.bounds.size.height) {
            self.gradientLayerLevel1.frame = self.bgContentView.bounds;
        }
    }
    
    if (self.gradientLayerLevel2) {
        
        if (self.gradientLayerLevel2.frame.size.width != self.bgContentView.bounds.size.width ||
            self.gradientLayerLevel2.frame.size.height != self.bgContentView.bounds.size.height) {
            self.gradientLayerLevel2.frame = self.bgContentView.bounds;
        }
    }
    
    if (self.gradientLayerLevel3) {
        
        if (self.gradientLayerLevel3.frame.size.width != self.bgContentView.bounds.size.width ||
            self.gradientLayerLevel3.frame.size.height != self.bgContentView.bounds.size.height) {
            self.gradientLayerLevel3.frame = self.bgContentView.bounds;
        }
    }
}

-(void)showLevel1GradientLayer {
    
    self.gradientLayerLevel1.hidden = NO;
    self.gradientLayerLevel2.hidden = YES;
    self.gradientLayerLevel3.hidden = YES;
}

-(void)showLevel2GradientLayer {

    self.gradientLayerLevel1.hidden = YES;
    self.gradientLayerLevel2.hidden = NO;
    self.gradientLayerLevel3.hidden = YES;
}

-(void)showLevel3GradientLayer {

    self.gradientLayerLevel1.hidden = YES;
    self.gradientLayerLevel2.hidden = YES;
    self.gradientLayerLevel3.hidden = NO;
}

-(void)hiddenAllGradientLayer {

    self.gradientLayerLevel1.hidden = YES;
    self.gradientLayerLevel2.hidden = YES;
    self.gradientLayerLevel3.hidden = YES;
}

-(void)addSubViews {
    
    self.contentView.backgroundColor = ClearColor;
    
    [self.contentView addSubview:self.cardView];
    self.cardView.backgroundColor = WhiteColor;
    [self.cardView cornerRadius:QYCornerRadiusAll radius:16];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(11);
        make.right.equalTo(self.contentView.mas_right).offset(-11);
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
    }];
    
    
    [self.cardView addSubview:self.bgContentView];
    
    self.bgContentView.backgroundColor = ClearColor;
    [self.bgContentView cornerRadius:QYCornerRadiusAll radius:16];
    [self.bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.cardView.mas_left).offset(1);
        make.right.equalTo(self.cardView.mas_right);
        make.top.equalTo(self.cardView.mas_top).offset(1);
        make.bottom.equalTo(self.cardView.mas_bottom);
    }];
    [self.bgContentView.layer insertSublayer:self.gradientLayerLevel1 atIndex:0];
    [self.bgContentView.layer insertSublayer:self.gradientLayerLevel2 atIndex:0];
    [self.bgContentView.layer insertSublayer:self.gradientLayerLevel3 atIndex:0];
    
    [self.cardView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.cardView.mas_left).offset(24);
        make.right.equalTo(self.cardView.mas_right).offset(-16);
        make.top.equalTo(self.cardView.mas_top).offset(15);
    }];
    
    
    [self.cardView addSubview:self.subTitleLabel];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.cardView.mas_left).offset(24);
        make.right.equalTo(self.cardView.mas_right).offset(-16);
        make.top.equalTo(self.titleLabel.mas_bottom);
    }];
    
    
    [self.cardView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.cardView.mas_left).offset(24);
        make.right.equalTo(self.cardView.mas_right).offset(-16);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(8);
        make.bottom.equalTo(self.cardView.mas_bottom).offset(-12);
    }];
    
    
    [self.cardView addSubview:self.priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.cardView.mas_right).offset(-16);
        make.bottom.equalTo(self.cardView.mas_bottom).offset(-12);
    }];
    
    
}

-(void)configCellWithModel:(MOTaskListModel *)model {
    
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.simple_descri;
    self.tagLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@人录制", nil),[NSString numberOfPeopleToStringWithUnit:model.user_task_num]];
    if ([model.price floatValue] > 0) {
        
        NSMutableAttributedString *currency_unitStr = [NSMutableAttributedString createWithString:model.currency_unit font:MOPingFangSCBoldFont(12) textColor:MainSelectColor];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.price attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(20),NSForegroundColorAttributeName: MainSelectColor}];
        NSMutableAttributedString *uitString = [[NSMutableAttributedString alloc] initWithString:model.unit?:@"" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(12),NSForegroundColorAttributeName: MainSelectColor}];
        [currency_unitStr appendAttributedString:string];
        [currency_unitStr appendAttributedString:uitString];
        self.priceLabel.attributedText = currency_unitStr;
    } else {
        self.priceLabel.text = @"";
        self.priceLabel.attributedText = nil;
    }
}


#pragma mark - setter && getter
-(MOView *)cardView {
    
    if (!_cardView) {
        _cardView = [MOView new];
    }
    
    return _cardView;
}

-(MOView *)bgContentView {
    
    if (!_bgContentView) {
        _bgContentView = [MOView new];
    }
    
    return _bgContentView;
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCBoldFont(16)];
    }
    
    return _titleLabel;
}

-(UILabel *)subTitleLabel {
    
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel labelWithText:@"" textColor:ColorAFAFAF font:MOPingFangSCMediumFont(13)];
    }
    
    return _subTitleLabel;
    
}


-(UILabel *)tagLabel {
    
    if (!_tagLabel) {
        _tagLabel = [UILabel labelWithText:@"" textColor:ColorAFAFAF font:MOPingFangSCMediumFont(10)];
    }
    
    return _tagLabel;
}

-(UILabel *)priceLabel {
    
    
    if (!_priceLabel) {
        _priceLabel = [UILabel labelWithText:@"" textColor:Color9A1E2E font:MOPingFangSCBoldFont(20)];
    }
    
    return _priceLabel;
}

- (CAGradientLayer *)gradientLayerLevel1 {
    
    if (!_gradientLayerLevel1) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)ColorF9ECD7.CGColor,(id)WhiteColor.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayerLevel1 = gradientLayer;
    }
    
    return _gradientLayerLevel1;
}


- (CAGradientLayer *)gradientLayerLevel2 {
    
    if (!_gradientLayerLevel2) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)ColorFBF2EA.CGColor,(id)WhiteColor.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayerLevel2 = gradientLayer;
    }
    
    return _gradientLayerLevel2;
}


- (CAGradientLayer *)gradientLayerLevel3 {
    
    if (!_gradientLayerLevel3) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)ColorE5F2F9.CGColor,(id)WhiteColor.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayerLevel3 = gradientLayer;
    }
    
    return _gradientLayerLevel3;
}
@end
