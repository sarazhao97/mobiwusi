//
//  MOMessageListTableViewCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOMessageListTableViewCell.h"

@implementation MOMessageListTableViewCell

-(void)addSubViews {
    
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView exerciseAmbiguityInLayout];
    self.contentView.backgroundColor = WhiteColor;
    [self.contentView addSubview:self.myContent];
    [self.myContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.myContent addSubview:self.inconImageView];
    [self.myContent addSubview:self.msgTitleLabel];
    [self.msgTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inconImageView.mas_right).offset(5);
        make.top.equalTo(self.myContent.mas_top).offset(11);
    }];
    
    [self.inconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.myContent.mas_left).offset(13);
        make.width.height.equalTo(@(18));
        make.centerY.equalTo(self.msgTitleLabel.mas_centerY);
    }];
    
    
    
    [self.myContent addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.msgTitleLabel.mas_right).offset(5);
        make.right.equalTo(self.myContent.mas_right).offset(-16);
        make.centerY.equalTo(self.msgTitleLabel.mas_centerY);
    }];
    
    [self.timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.myContent addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.myContent.mas_left).offset(16);
        make.right.equalTo(self.myContent.mas_right).offset(-16);
        make.height.equalTo(@(1));
        make.top.equalTo(self.myContent.mas_top).offset(41);
    }];
    
    [self.myContent addSubview:self.msgTextLabel];
    [self.msgTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.myContent.mas_left).offset(13);
        make.right.equalTo(self.myContent.mas_right).offset(-13);
        make.top.equalTo(self.lineView.mas_bottom).offset(8);
        make.bottom.equalTo(self.myContent.mas_bottom).offset(-17);
    }];
    self.msgTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.msgTextLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
}


-(void)configWithModel:(MOMessageListItemModel *)model {
    
    [self.inconImageView sd_setImageWithURL:[NSURL URLWithString:model.icon?:@""]];
    self.msgTitleLabel.text = model.title;
    self.timeLabel.text = model.create_time;
    self.msgTextLabel.text = model.content;
}


#pragma mark - setter && getter
-(UIImageView *)inconImageView {
    
    if (!_inconImageView) {
        _inconImageView = [UIImageView new];
    }
    return _inconImageView;
}

-(UILabel *)msgTitleLabel {
    if (!_msgTitleLabel) {
        _msgTitleLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCBoldFont(13)];
    }
    
    return _msgTitleLabel;
}

-(UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel labelWithText:@"" textColor:Color9B9B9B font:MOPingFangSCMediumFont(11)];
    }
    
    return _timeLabel;
}

-(MOView *)lineView {
    
    if (!_lineView) {
        _lineView = [MOView new];
        _lineView.backgroundColor = ColorF2F2F2;
    }
    return _lineView;
}

-(UILabel *)msgTextLabel {
    if (!_msgTextLabel) {
        _msgTextLabel = [UILabel labelWithText:@"" textColor:Color333333 font:MOPingFangSCMediumFont(12)];
        _msgTextLabel.numberOfLines = 0;
    }
    
    return _msgTextLabel;
}

-(MOView *)myContent {
    
    if (!_myContent) {
        _myContent = [MOView new];
    }
    return _myContent;
}
@end
