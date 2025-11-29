//
//  MOBaseScheduleCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOBaseScheduleCell.h"

@implementation MOBaseScheduleCell

-(void)addSubViews {
    
    self.contentView.backgroundColor = ClearColor;
    [self.contentView addSubview:self.scheduleCircleView];
    [self.contentView addSubview:self.timeLabel];
    [self.scheduleCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(12));
        make.width.equalTo(@(8));
        make.height.equalTo(@(8));
        make.centerY.equalTo(self.timeLabel.mas_centerY);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(30);
        make.right.equalTo(self.contentView.mas_right).offset(-8);
        make.top.equalTo(self.contentView.mas_top).offset(16);
    }];
    
    
    [self.contentView addSubview:self.scheduleVerticalTopView];
    [self.scheduleVerticalTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scheduleCircleView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.scheduleCircleView.mas_top);
        make.width.equalTo(@(2));
    }];
    
    
    [self.contentView addSubview:self.scheduleVerticalBottomView];
    [self.scheduleVerticalBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scheduleCircleView.mas_centerX);
        make.top.equalTo(self.scheduleCircleView.mas_bottom);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.equalTo(@(2));
    }];
    
    [self.contentView addSubview:self.dataContentView];
    [self.dataContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(34);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(2);
        make.right.equalTo(self.contentView.mas_right).offset(-8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(1);
    }];
    
    [self.dataContentView.msgBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.dataContentView.editBtn addTarget:self action:@selector(msgBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)configCellData:(MOUserTaskDataModel *)data {
    
}

-(void)editBtnClick{
    
    if (self.didMsgBtnClick) {
        self.didMsgBtnClick();
    }
}

-(void)msgBtnClick {
    
    if (self.didEditBtnClick) {
        self.didEditBtnClick();
    }
}

+(NSMutableAttributedString *)createTryTagAttributedStringWithTitle:(NSString *)dataTitle {
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] init];
    
    UILabel *label = [UILabel labelWithText:NSLocalizedString(@"测试数据",nil) textColor:WhiteColor font:MOPingFangSCMediumFont(10)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = ColorFC9E09;
    label.frame = CGRectMake(0, 0, 50, 15);
    [label cornerRadius:QYCornerRadiusAll radius:3];
    NSMutableAttributedString *str2 =  [NSMutableAttributedString yy_attachmentStringWithContent:label contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(50, 15) alignToFont:MOPingFangSCMediumFont(15) alignment:YYTextVerticalAlignmentCenter];
    [str1 appendAttributedString:str2];
    
    NSString *taskTitle = [NSString stringWithFormat:@" %@",dataTitle?:@""];
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:taskTitle attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:BlackColor}];
    [str1 appendAttributedString:str3];
    return str1;
}

+(NSMutableAttributedString *)createNoTryTagAttributedStringWithTitle:(NSString *)dataTitle {
    
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] init];
    
    NSString *taskTitle = [NSString stringWithFormat:@"%@",dataTitle?:@""];
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:taskTitle attributes:@{NSFontAttributeName:MOPingFangSCMediumFont(15),NSForegroundColorAttributeName:BlackColor}];
    [str1 appendAttributedString:str3];
    return str1;
}

#pragma mark - setter && getter
-(UILabel *)timeLabel {
    
    if (!_timeLabel) {
        _timeLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCMediumFont(13)];
    }
    
    return _timeLabel;
}

-(MOBaseDataContentView *)dataContentView {
    
    if (!_dataContentView) {
        _dataContentView = [MOBaseDataContentView new];
        _dataContentView.backgroundColor = WhiteColor;
        [_dataContentView cornerRadius:QYCornerRadiusAll radius:10];
    }
    
    return _dataContentView;
}


-(MOView *)scheduleCircleView {
    
    if (!_scheduleCircleView) {
        _scheduleCircleView = [MOView new];
        _scheduleCircleView.backgroundColor = ClearColor;
        [_scheduleCircleView cornerRadius:QYCornerRadiusAll radius:4 borderWidth:2 borderColor:MainSelectColor];
    }
    
    return _scheduleCircleView;
}



-(MOView *)scheduleVerticalTopView {
    
    if (!_scheduleVerticalTopView) {
        _scheduleVerticalTopView = [MOView new];
        _scheduleVerticalTopView.backgroundColor = ColorD9DAE3;
    }
    
    return _scheduleVerticalTopView;
}

-(MOView *)scheduleVerticalBottomView {
    
    if (!_scheduleVerticalBottomView) {
        _scheduleVerticalBottomView = [MOView new];
        _scheduleVerticalBottomView.backgroundColor = ColorD9DAE3;
    }
    
    return _scheduleVerticalBottomView;
}


@end


@implementation MOBaseDataContentView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.categoryDataView];
    [self.categoryDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
    }];
    
	[self addSubview:self.msgBtn];
	[self.msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
			
		make.right.equalTo(self.mas_right).offset(-10);
		make.top.equalTo(self.categoryDataView.mas_bottom);
		make.bottom.equalTo(self.mas_bottom).offset(-11);
		make.width.greaterThanOrEqualTo(@(50));
		
	}];
    
    [self addSubview:self.editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
		make.right.equalTo(self.msgBtn.mas_left).offset(-5);
		make.centerY.equalTo(self.msgBtn.mas_centerY);
		make.width.greaterThanOrEqualTo(@(50));
    }];
    
    
    [self addSubview:self.didTageLabel];
    [self.didTageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.equalTo(self.mas_left).offset(13);
        make.centerY.equalTo(self.msgBtn.mas_centerY);
    }];
	
	[self addSubview:self.locationBtn];
	[self.locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
			
		make.left.equalTo(self.mas_left).offset(13);
		make.centerY.equalTo(self.msgBtn.mas_centerY);
	}];
    
    
    
    
    [self addSubview:self.redDotView];
    [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.centerX.equalTo(self.msgBtn.mas_right);
        make.centerY.equalTo(self.msgBtn.mas_centerY).offset(-5);
        make.width.height.equalTo(@(8));
    }];

}


#pragma mark - setter && getter
-(MOView *)categoryDataView {
    
    if (!_categoryDataView) {
        _categoryDataView = [MOView new];
    }
    return _categoryDataView;
}

-(UILabel *)didTageLabel {
    
    if (!_didTageLabel) {
        _didTageLabel = [UILabel labelWithText:@"" textColor:Color626262 font:MOPingFangSCMediumFont(10)];
		_didTageLabel.hidden = YES;
    }
    
    return _didTageLabel;
}


-(MOButton *)msgBtn {
    
    if (!_msgBtn) {
        _msgBtn = [MOButton new];
        [_msgBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
        [_msgBtn setImage:[UIImage imageNamedNoCache:@"icon_task_new_msg.png"]];
		_msgBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    
    return _msgBtn;
}

-(MOView *)redDotView {
    
    if (!_redDotView) {
        _redDotView = [MOView new];
        _redDotView.backgroundColor = ColorFF0000;
        [_redDotView cornerRadius:QYCornerRadiusAll radius:4];
        _redDotView.userInteractionEnabled = NO;
    }
    return _redDotView;
}

-(MOButton *)editBtn {
    
    if (!_editBtn) {
        _editBtn = [MOButton new];
        [_editBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
        [_editBtn setImage:[UIImage imageNamedNoCache:@"icon_task_new_msg.png"]];
		_editBtn.hidden = YES;
//		_editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    return _editBtn;
}

-(MOButton *)locationBtn {
	
	if (!_locationBtn) {
		_locationBtn = [MOButton new];
		[_locationBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
		[_locationBtn setImage:[UIImage imageNamedNoCache:@"icon_data_location_14.png"]];
		_locationBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
		_locationBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
		[_locationBtn fixAlignmentBUG];
		[_locationBtn setTitle:@"" titleColor:Color828282 bgColor:ClearColor font:MOPingFangSCMediumFont(11)];
	}
	
	return _locationBtn;
}
@end
