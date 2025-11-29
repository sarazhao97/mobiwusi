//
//  MOFillTaskTopicTitleView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOFillTaskTopicTitleView.h"

@implementation MOFillTaskTopicTitleView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(21));
        make.top.equalTo(self.mas_top).mas_offset(12);
        make.right.equalTo(self.mas_right).offset(-21);
    }];
    
    
    [self addSubview:self.leftContentView];
    [self.leftContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(21));
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
        make.height.equalTo(@(14));
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    
    [self.leftContentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.leftContentView.mas_left);
        make.top.equalTo(self.leftContentView.mas_top);
        make.bottom.equalTo(self.leftContentView.mas_bottom);
        make.width.equalTo(@(isCurrentLanguageChinese?56:70));
    }];
    
    [self.leftContentView addSubview:self.indexLabel];
    [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.tagLabel.mas_right).offset(4);
        make.centerY.equalTo(self.leftContentView.mas_centerY);
        make.right.equalTo(self.leftContentView.mas_right).offset(-3);
    }];
    
    
    
    
    
    [self addSubview:self.tidLabel];
    [self.tidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.leftContentView.mas_right).offset(5);
        make.centerY.equalTo(self.leftContentView.mas_centerY);
    }];
    
}

-(void)configViewWithModel:(MOTaskListModel *)model withIndex:(NSInteger)index total:(NSInteger)total {
    
    self.titleLabel.text = model.title;
    
    
    if (model.topic_type == 1) {
        self.tagLabel.backgroundColor = ColorFC9E09;
        self.tagLabel.text = NSLocalizedString(@"测试数据",nil);
        self.indexLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld/%ld条", nil),(long)index ,(long)total];
        self.indexLabel.textColor = ColorFC9E09;
        self.leftContentView.backgroundColor = [ColorFC9E09 colorWithAlphaComponent:0.2];
    } else {
        
        self.tagLabel.text = NSLocalizedString(@"正式数据", nil);
        self.tagLabel.backgroundColor = MainSelectColor;
        self.indexLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%ld/%ld条", nil),(long)index ,(long)total];
        self.indexLabel.textColor = MainSelectColor;
        self.leftContentView.backgroundColor = [MainSelectColor colorWithAlphaComponent:0.2];
    }
    self.tidLabel.text = [NSString stringWithFormat:@"PoID:%@",model.task_no];
}

-(void)configNoTidViewWithModel:(MOTaskListModel *)model withIndex:(NSInteger)index{
    
    NSInteger allTotal = model.topic_num;
    if (model.topic_type == 1) {
        allTotal = model.try_topic_num;
    }
    [self configViewWithModel:model withIndex:index total:allTotal];
    self.tidLabel.text = @"";
}

#pragma mark - setter && getter
-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCBoldFont(18)];
		_titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.numberOfLines = 0;
        
    }
    return _titleLabel;
}

-(MOView *)leftContentView {
    
    if (!_leftContentView) {
        _leftContentView = [MOView new];
        [_leftContentView cornerRadius:QYCornerRadiusAll radius:4];
        _leftContentView.backgroundColor = [ColorFC9E09 colorWithAlphaComponent:0.2];
    }
    
    return _leftContentView;
}

-(UILabel *)tagLabel {
    
    if (!_tagLabel) {
        _tagLabel = [UILabel labelWithText:@"" textColor:WhiteColor font:MOPingFangSCMediumFont(10)];
        [_tagLabel cornerRadius:QYCornerRadiusAll radius:4];
        _tagLabel.backgroundColor = ColorFC9E09;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _tagLabel;
}


-(UILabel *)indexLabel {
    
    if (!_indexLabel) {
        _indexLabel = [UILabel labelWithText:@"" textColor:ColorFC9E09 font:MOPingFangSCMediumFont(10)];
        
    }
    return _indexLabel;
}

-(UILabel *)tidLabel {
    
    if (!_tidLabel) {
        _tidLabel = [UILabel labelWithText:@"" textColor:Color626262 font:MOPingFangSCMediumFont(10)];
        
    }
    return _tidLabel;
}

@end
