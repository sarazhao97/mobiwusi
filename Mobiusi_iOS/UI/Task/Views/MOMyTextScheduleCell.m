//
//  MOMyTextScheduleCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOMyTextScheduleCell.h"

@implementation MOMyTextScheduleCell

-(void)addSubViews {
    [super addSubViews];
    [self.dataContentView.categoryDataView addSubview:self.dataTitle];
    self.dataTitle.preferredMaxLayoutWidth = SCREEN_WIDTH - 13 - 10 - 34 - 8;
    [self.dataTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(@(9));
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
    }];
    
    [self.dataContentView.categoryDataView addSubview:self.attachmentFilesView];
    [self.attachmentFilesView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
    }];
    
    
}

-(void)configCellData:(MOUserTaskDataModel *)data {
    
    [self.attachmentFilesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.timeLabel.text = data.upload_time;
    
	if (data.topic_type == 1) {
		self.dataTitle.attributedText = [MOBaseScheduleCell createTryTagAttributedStringWithTitle:data.task_title.length ? data.task_title:data.idea];
	} else {
		self.dataTitle.attributedText = [MOBaseScheduleCell createNoTryTagAttributedStringWithTitle:data.task_title.length ? data.task_title:data.idea];
	}
	
	if (data.location.length > 0) {
		self.dataContentView.locationBtn.hidden = NO;
		[self.dataContentView.locationBtn setTitles:data.location];
	}else {
		self.dataContentView.locationBtn.hidden = YES;
	}
	
    self.dataContentView.redDotView.hidden = !data.is_not_read;
    NSInteger fileCount = data.result.count;
    self.dataContentView.didTageLabel.text = [NSString stringWithFormat:@"DID:%ld",(long)data.model_id];
    self.dataContentView.didTageLabel.hidden = YES;
    MODocFileItemView *currentItem;
    for (int i = 0; i < fileCount; i++) {
        MODocFileItemView *fileItem = [MODocFileItemView new];
        fileItem.backgroundColor = ColorEDEEF5;
        [fileItem cornerRadius:QYCornerRadiusAll radius:10];
        MOUserTaskDataResultModel *model = data.result[i];
        fileItem.fileNameLabel.text = model.file_name;
		WEAKSELF
		fileItem.didCilck = ^{
			if (weakSelf.didClickFile) {
				weakSelf.didClickFile(i);
			}
		};
        [self.attachmentFilesView addSubview:fileItem];
        if (currentItem) {
            [fileItem mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(currentItem.mas_bottom).offset(10);
                make.left.equalTo(self.attachmentFilesView.mas_left);
                make.right.equalTo(self.attachmentFilesView.mas_right);
                make.height.equalTo(@(35));
            }];
            
        } else {
            [fileItem mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.equalTo(self.attachmentFilesView.mas_top).offset(0);
                make.left.equalTo(self.attachmentFilesView.mas_left);
                make.right.equalTo(self.attachmentFilesView.mas_right);
                make.height.equalTo(@(35));
            }];
        }
        
        currentItem = fileItem;
    }
    
    if (data.result.count == 1 && data.result.firstObject.data_param.length) {
        CGFloat maxY = fileCount *35 + (fileCount - 1)* 10;
        [self.attachmentFilesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(@(13));
            make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
            make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
            make.height.equalTo(@(maxY));
        }];
        
        NSString *data_paramSTr = StringWithFormat(NSLocalizedString(@"参数：%@", nil),data.result.firstObject.data_param);
        UILabel *data_other_param = [UILabel labelWithText:data_paramSTr textColor:Color828282 font:MOPingFangSCMediumFont(11)];
        [self.attachmentFilesView addSubview:data_other_param];
        [data_other_param mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.top.equalTo(currentItem.mas_bottom).offset(10);
            make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
            make.bottom.equalTo(self.dataContentView.categoryDataView.mas_bottom).offset(-10);
        }];
        
        
    } else {
        
        CGFloat maxY = fileCount *35 + (fileCount - 1)* 10;
        [self.attachmentFilesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(@(13));
            make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
            make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
            make.height.equalTo(@(maxY));
            make.bottom.equalTo(self.dataContentView.categoryDataView.mas_bottom).offset(-10);
        }];
    }
    
}


-(YYLabel *)dataTitle {
    
    if (!_dataTitle) {
        _dataTitle = [YYLabel new];
        _dataTitle.numberOfLines = 0;
		_dataTitle.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    return _dataTitle;
}

-(MOView *)attachmentFilesView {
    
    if (!_attachmentFilesView) {
        _attachmentFilesView = [MOView new];
        
    }
    
    return _attachmentFilesView;
}

@end
