//
//  MOLoginBottomView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

#import "MOLoginBottomView.h"

@implementation MOLoginBottomView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.wxLoginBtn];
    [self.wxLoginBtn addTarget:self action:@selector(wxLoginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.wxLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).multipliedBy(0.5);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.aliPayLoginBtn];
    [self.aliPayLoginBtn addTarget:self action:@selector(aliPayLoginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.aliPayLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    NSString *aliPay = @"alipay://";
    BOOL aliPayInstall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:aliPay]];
    if (!aliPayInstall) {
        self.aliPayLoginBtn.hidden = YES;
    }
    
    
    [self addSubview:self.appleIdLoginBtn];
    [self.appleIdLoginBtn addTarget:self action:@selector(appleIdLoginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.appleIdLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_centerX).multipliedBy(1.5);
        make.centerY.equalTo(self.mas_centerY);
    }];
}


-(void)wxLoginBtnClick {
    
    if (self.loginBtnClick) {
        self.loginBtnClick(LoginTypeWX);
    }
    
}

-(void)aliPayLoginBtnClick {
    
    if (self.loginBtnClick) {
        self.loginBtnClick(LoginTypeAliPay);
    }
    
}

-(void)appleIdLoginBtnClick {
    
    if (self.loginBtnClick) {
        self.loginBtnClick(LoginTypeAppleId);
    }
    
}

-(MOButton *)wxLoginBtn {
    
    if (!_wxLoginBtn) {
        _wxLoginBtn = [MOButton new];
        [_wxLoginBtn setImage:[UIImage imageNamedNoCache:@"data_icon_login_wx"]];
    }
    return _wxLoginBtn;
}

-(MOButton *)aliPayLoginBtn {
    
    if (!_aliPayLoginBtn) {
        _aliPayLoginBtn = [MOButton new];
        [_aliPayLoginBtn setImage:[UIImage imageNamedNoCache:@"data_icon_login_AliPay"]];
    }
    return _aliPayLoginBtn;
}


-(MOButton *)appleIdLoginBtn {
    
    if (!_appleIdLoginBtn) {
        _appleIdLoginBtn = [MOButton new];
        [_appleIdLoginBtn setImage:[UIImage imageNamedNoCache:@"data_icon_login_AppleId"]];
    }
    return _appleIdLoginBtn;
}
@end
