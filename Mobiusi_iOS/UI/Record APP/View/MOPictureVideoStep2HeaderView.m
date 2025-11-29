//
//  MOPictureVideoStep2HeaderView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOPictureVideoStep2HeaderView.h"

@implementation MOPictureVideoStep2HeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubviews];
    }
    return self;
}

-(void)addSubviews {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(5);
        make.centerY.equalTo(self.mas_centerY);
        
    }];
    
    [self addSubview:self.completeBtn];
    [self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.titleLabel.mas_right).offset(3);
        make.centerY.equalTo(self.mas_centerY).offset(-1);
    }];
}

-(void)setWanringTitle:(NSString *)title {
    [self.completeBtn setImage:nil];
    [self.completeBtn setTitle:title titleColor:ColorFC9E09 bgColor:ClearColor font:MOPingFangSCMediumFont(12)];
}
-(void)setSuccessTitle:(NSString *)title {
    [self.completeBtn setImage:[UIImage imageNamedNoCache:@"icon_data_correct.png"]];
    [self.completeBtn setTitle:title titleColor:Color34C759 bgColor:ClearColor font:MOPingFangSCMediumFont(12)];
}


#pragma mark - setter && getter
-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:Color626262 font:MOPingFangSCMediumFont(12)];
    }
    return _titleLabel;
}


-(MOButton *)completeBtn {
    
    if (!_completeBtn) {
        _completeBtn = [MOButton new];
        [_completeBtn setTitle:@"" titleColor:ColorFC9E09 bgColor:ClearColor font:MOPingFangSCMediumFont(12)];
        _completeBtn.enabled = NO;
    }
    
    return _completeBtn;
}
@end
