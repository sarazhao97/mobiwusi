//
//  MOPlainTextFillTaskStep2View.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOPlainTextFillTaskStep2View.h"
#import <UITextView+ZWPlaceHolder.h>

@implementation MOPlainTextFillTaskStep2View



-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(21);
        make.top.equalTo(self.mas_top).offset(10);
    }];
    
    
    [self addSubview:self.exampleBtn];
    [self.exampleBtn addTarget:self action:@selector(exampleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.exampleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-28);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(11);
        make.right.equalTo(self.mas_right).offset(-11);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.bottom.equalTo(self.mas_bottom).offset(10);
        
    }];
    
    [self.contentView addSubview:self.titleInput];
    [self.titleInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(21);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.height.equalTo(@(30));
        
    }];
//    self.titleInput.delegate = self;
    self.titleLengthCountLabel.hidden = YES;
    [self.contentView addSubview:self.titleLengthCountLabel];
    [self.titleLengthCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleInput.mas_right);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.centerY.equalTo(self.titleInput.mas_centerY);
    }];
    
    
    [self.contentView addSubview:self.textInput];
    [self.textInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(21);
        make.top.equalTo(self.titleInput.mas_bottom).offset(25);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.height.equalTo(@(190));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
    }];
}

-(void)exampleBtnClick {
    
    if (self.didExampleBtnClick) {
        self.didExampleBtnClick();
    }
}


#pragma mark - setter && getter
-(MOView *)contentView {
    
    if (!_contentView) {
        _contentView = [MOView new];
        _contentView.backgroundColor = WhiteColor;
        [_contentView cornerRadius:QYCornerRadiusAll radius:20];
    }
    return _contentView;
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:NSLocalizedString(@"Step2：输入文本", nil) textColor:Color626262 font:MOPingFangSCMediumFont(12)];
    }
    return _titleLabel;
}

-(MOButton *)exampleBtn {
    
    if (!_exampleBtn) {
        _exampleBtn = [MOButton new];
        [_exampleBtn setTitle:NSLocalizedString(@"样例", nil) titleColor:Color34C759 bgColor:ClearColor font:MOPingFangSCBoldFont(12)];
        [_exampleBtn setImage:[UIImage imageNamedNoCache:@"icon_data_light_bulb.png"]];
    }
    
    return _exampleBtn;
}

- (UITextField *)titleInput {
    
    if (!_titleInput) {
        _titleInput = [UITextField new];
        _titleInput.font = MOPingFangSCMediumFont(13);
        _titleInput.textColor = BlackColor;
        _titleInput.placeholder = NSLocalizedString(@"请输入文本标题...", nil);
    }
    return _titleInput;
}

-(UILabel *)titleLengthCountLabel {
    
    if (!_titleLengthCountLabel) {
        _titleLengthCountLabel = [UILabel labelWithText:@"0/20" textColor:Color626262 font:MOPingFangSCMediumFont(12)];
    }
    return _titleLengthCountLabel;
}

- (UITextView *)textInput {
    if (!_textInput) {
        
        _textInput = [UITextView new];
        _textInput.textColor = BlackColor;
        _textInput.font = MOPingFangSCMediumFont(12);
        _textInput.showsVerticalScrollIndicator = YES;
        _textInput.placeholder = NSLocalizedString(@"请输入文本内容...", nil);
    }
    
    return _textInput;
}

@end
