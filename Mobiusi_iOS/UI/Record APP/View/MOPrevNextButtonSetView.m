//
//  MOPrevNextButtonSetView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/14.
//

#import "MOPrevNextButtonSetView.h"

@implementation MOPrevNextButtonSetView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.prevBtn];
    [self.prevBtn addTarget:self action:@selector(prevBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left);
        make.height.equalTo(@(55));
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    [self addSubview:self.nextBtn];
    [self.nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.prevBtn.mas_right).offset(10);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(55));
        make.width.equalTo(self.prevBtn.mas_width);
        make.centerY.equalTo(self.prevBtn.mas_centerY);
    }];
    
    [self addSubview:self.saveBtn];
    [self.saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.saveBtn.hidden = YES;
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(10);
        make.height.equalTo(@(55));
        make.top.equalTo(self.mas_top);
    }];
}

-(void)prevBtnClick {
    
    if (self.didPrevBtnClick) {
        self.didPrevBtnClick();
    }
}

-(void)nextBtnClick {
    
    if (self.didNextBtnClick) {
        self.didNextBtnClick();
    }
}

-(void)saveBtnClick{
    
    if (self.didsaveBtnClick) {
        self.didsaveBtnClick();
    }
}


#pragma mark - setter && getter
-(MOButton *)prevBtn {
    
    if (!_prevBtn) {
        _prevBtn = [MOButton new];
        [_prevBtn setTitle:NSLocalizedString(@"上一条", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCBoldFont(16)];
        [_prevBtn cornerRadius:QYCornerRadiusAll radius:14];
    }
    return _prevBtn;
}

-(MOButton *)nextBtn {
    
    if (!_nextBtn) {
        _nextBtn = [MOButton new];
        [_nextBtn setTitle:NSLocalizedString(@"下一条", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCBoldFont(16)];
        [_nextBtn cornerRadius:QYCornerRadiusAll radius:14];
    }
    return _nextBtn;
    
}

-(MOButton *)saveBtn {
    
    if (!_saveBtn) {
        _saveBtn = [MOButton new];
        [_saveBtn setTitle:NSLocalizedString(@"保存", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCBoldFont(16)];
        [_saveBtn cornerRadius:QYCornerRadiusAll radius:14];
    }
    return _saveBtn;
    
}

@end
