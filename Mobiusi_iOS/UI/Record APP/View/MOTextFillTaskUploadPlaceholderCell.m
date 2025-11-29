//
//  MOTextFillTaskUploadPlaceholderCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOTextFillTaskUploadPlaceholderCell.h"


@implementation MOTextFillTaskUploadPlaceholderCell

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
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
    }];
    
    
    
    [self.bgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bgView.mas_centerY);
        make.centerX.equalTo(self.bgView.mas_centerX).offset(11);
    }];
    
    [self.bgView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bgView.mas_centerY);
        make.right.equalTo(self.titleLabel.mas_left).offset(-6);
    }];
    
}


#pragma mark - setter && getter
-(MOView *)bgView {
    
    if (!_bgView) {
        _bgView = [MOView new];
        [_bgView cornerRadius:QYCornerRadiusAll radius:10];
        _bgView.backgroundColor = ColorEDEEF5;
    }
    return _bgView;
}

-(UIImageView *)iconImageView {
    
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.image = [UIImage imageNamedNoCache:@"icon_data_text_upload_attchment.png"];
    }
    
    return _iconImageView;
}


-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:NSLocalizedString(@"本地上传", nil) textColor:Color626262 font:MOPingFangSCMediumFont(12)];
    }
    
    return _titleLabel;
}


@end
