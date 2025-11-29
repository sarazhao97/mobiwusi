//
//  MOWithdrawalRecordCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOWithdrawalRecordCell.h"

@implementation MOWithdrawalRecordCell

-(void)addSubViews {
    
    self.contentView.backgroundColor = WhiteColor;
    [self.contentView addSubview:self.amountLabel];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(23.5);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    [self.contentView addSubview:self.amountLabel];
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(23.5);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.rightContentView];
    [self.rightContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.amountLabel.mas_right);
    }];
    
    
    [self.rightContentView addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.rightContentView.mas_top);
        make.right.equalTo(self.rightContentView.mas_right);
    }];
    
    [self.rightContentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.stateLabel.mas_bottom).offset(10);
        make.right.equalTo(self.rightContentView.mas_right);
        make.bottom.equalTo(self.rightContentView.mas_bottom);
    }];
    
    [self.contentView addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@(1));
        make.left.equalTo(self.contentView.mas_left).offset(17);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
    
}

-(void)configCellWithModel:(MOWithdrawalRecordItemModel *)model {
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"￥", nil) attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(12),NSForegroundColorAttributeName: ColorA2002D}];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:model.money?:@"" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(24),NSForegroundColorAttributeName: ColorA2002D}];
    [string appendAttributedString:string1];
    self.amountLabel.attributedText = string;
    ////提现状态：0审核中 1打款中 2已打款 3审核失败 4打款失败
    NSDictionary *stateDict = @{
        @(0):@"审核中",
        @(1):@"打款中",
        @(2):@"已打款",
        @(3):@"审核失败",
        @(4):@"打款失败"
    };
    NSDictionary *stateColorDict = @{
        @(0):ColorFFAE00,
        @(1):ColorFFAE00,
        @(2):Color333333,
        @(3):ColorFF4A4A,
        @(4):ColorFF4A4A
    };
    NSString *stateStr = stateDict[@(model.status)];
    UIColor *stateColor = stateColorDict[@(model.status)];
    self.stateLabel.text = stateStr?:@"";
    self.stateLabel.textColor = stateColor;
    self.timeLabel.text = model.date_name?:@"";
    
    
    
}


#pragma mark - getter setter
-(UILabel *)amountLabel {
    
    if (!_amountLabel) {
        _amountLabel = [UILabel new];
    }
    return _amountLabel;
}

-(MOView *)rightContentView {
    
    if (!_rightContentView) {
        _rightContentView = [MOView new];
    }
    return _rightContentView;
}

-(UILabel *)stateLabel {
    
    if (!_stateLabel) {
        _stateLabel = [UILabel labelWithText:@"" textColor:Color333333 font:MOPingFangSCMediumFont(12)];
    }
    return _stateLabel;
}

-(UILabel *)timeLabel {
    
    if (!_timeLabel) {
        _timeLabel = [UILabel labelWithText:@"" textColor:Color959998 font:MOPingFangSCMediumFont(12)];
    }
    return _timeLabel;
}

-(MOView *)bottomLine {
    
    if (!_bottomLine) {
        _bottomLine = [MOView new];
        _bottomLine.backgroundColor = ColorEDEEF5;
    }
    return _bottomLine;
}
@end
