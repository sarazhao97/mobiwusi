//
//  MOTaskIntroductionView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import "MOTaskIntroductionView.h"

@implementation MOTaskIntroductionView
-(void)addSubViewsInFrame:(CGRect)frame {
    
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(20);
        make.top.equalTo(self.mas_top).offset(19);
    }];
    
    [self addSubview:self.markView];
    [self.markView cornerRadius:QYCornerRadiusAll radius:10];
    [self.markView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(8);
        make.width.equalTo(@(4));
        make.height.equalTo(@(13));
        make.centerY.equalTo(self.titleLabel.mas_centerY);
    }];
    
    [self addSubview:self.exampleBtn];
    [self.exampleBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    [self.exampleBtn addTarget:self action:@selector(exampleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.exampleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-17);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
    }];
    
    
    
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(21);
        make.right.equalTo(self.mas_right).offset(-17);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(9);
        make.bottom.equalTo(self.mas_bottom).offset(-20);
    }];
}

-(void)exampleBtnClick {
    
    if (self.didExampleBtnClick) {
        self.didExampleBtnClick();
    }
}

-(MOView *)markView {
    
    if (!_markView) {
        _markView = [MOView new];
        _markView.backgroundColor = Color9A1E2E;
    }
    return _markView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCHeavyFont(16)];
    }
    return _titleLabel;
}

-(UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}


-(MOButton *)exampleBtn {
    
    if (!_exampleBtn) {
        _exampleBtn = [MOButton new];
        [_exampleBtn setTitle:NSLocalizedString(@"样例", nil) titleColor:Color34C759 bgColor:ClearColor font:MOPingFangSCBoldFont(12)];
        [_exampleBtn setImage:[UIImage imageNamedNoCache:@"icon_data_light_bulb.png"]];
    }
    
    return _exampleBtn;
}

@end
