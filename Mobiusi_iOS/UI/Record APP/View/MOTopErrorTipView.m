//
//  MOTopErrorTipView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/14.
//

#import "MOTopErrorTipView.h"

@implementation MOTopErrorTipView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    self.backgroundColor = [ColorCCB94C colorWithAlphaComponent:0.1];
    [self addSubview:self.errorLabel];
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(21);
        make.top.equalTo(self.mas_top).offset(10);
        make.right.equalTo(self.mas_right).offset(17);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    
}

-(UILabel *)errorLabel {
    
    if (!_errorLabel) {
        _errorLabel = [UILabel labelWithText:@"" textColor:ColorCCB94C font:MOPingFangSCFont(12)];
    }
    return _errorLabel;
}

@end
