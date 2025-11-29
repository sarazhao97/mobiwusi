//
//  MOFillTaskTopicStep1View.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOFillTaskTopicStep1View.h"

@implementation MOFillTaskTopicStep1View

-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).offset(18);
        make.left.equalTo(self.mas_left).offset(21);
        make.right.equalTo(self.mas_right).offset(-21);
    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.left.equalTo(self.mas_left).offset(11);
        make.right.equalTo(self.mas_right).offset(-11);
        make.bottom.equalTo(self.mas_bottom).offset(-1);
    }];
    
    
    [self.contentView addSubview:self.requireLabel];
    [self.requireLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contentView.mas_top).offset(15);
        make.left.equalTo(self.contentView.mas_left).offset(17);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
    }];
    
    
    [self.contentView addSubview:self.viewRequireBtn];
    [self.viewRequireBtn addTarget:self action:@selector(viewRequireBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewRequireBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.requireLabel.mas_bottom).offset(3);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
}

-(void)setRequreStringToAttributedString:(NSString *)requreString {
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        // 设置行间距为 10 点
    paragraphStyle.lineSpacing = 10;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:requreString?:@"" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(14),NSForegroundColorAttributeName: BlackColor,NSParagraphStyleAttributeName:paragraphStyle}];
    self.requireLabel.attributedText = string;
}

-(void)viewRequireBtnClick {
    
    if (self.didViewRequireBtnClick) {
        self.didViewRequireBtnClick();
    }
}



#pragma mark - setter && getter
-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:Color626262 font:MOPingFangSCMediumFont(12)];
        
    }
    return _titleLabel;
}

-(MOView *)contentView {
    
    
    if (!_contentView) {
        _contentView = [MOView new];
        _contentView.backgroundColor = WhiteColor;
        [_contentView cornerRadius:QYCornerRadiusAll radius:20];
    }
    return _contentView;
    
}


-(UILabel *)requireLabel {
    
    if (!_requireLabel) {
        _requireLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCMediumFont(14)];
        _requireLabel.numberOfLines = 3;
    }
    return _requireLabel;
}

-(MOButton *)viewRequireBtn {
    
    if (!_viewRequireBtn) {
        _viewRequireBtn = [MOButton new];
        [_viewRequireBtn setTitle:NSLocalizedString(@"查看要求", nil) titleColor:MainSelectColor bgColor:ClearColor font:MOPingFangSCBoldFont(12)];
        [_viewRequireBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    
    return _viewRequireBtn;
    
}

@end
