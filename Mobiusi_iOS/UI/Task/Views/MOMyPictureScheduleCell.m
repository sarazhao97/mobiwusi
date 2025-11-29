//
//  MOMyPictureScheduleCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOMyPictureScheduleCell.h"

@implementation MOMyPictureScheduleCell

-(void)addSubViews {
    
    [super addSubViews];
    [self.dataContentView.categoryDataView addSubview:self.dataTitle];
    self.dataTitle.preferredMaxLayoutWidth = SCREEN_WIDTH - 13 - 10 - 34 - 8;
    [self.dataTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(@(9));
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
    }];
    
    [self.dataContentView.categoryDataView addSubview:self.attachmentImagesView];
    [self.attachmentImagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
    }];
    
    
}

-(void)configeImageView:(UIImageView *)imageView imageIndex:(NSInteger)imageIndex model:(MOUserTaskDataModel *)data {
    
    NSInteger fileCount = data.result.count;
    if (fileCount >= imageIndex + 1) {
        MOUserTaskDataResultModel *model = data.result[imageIndex];
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.cate == 4?model.snapshot:model.path]];
        if (model.cate == 4) {
            UIImageView *image = [UIImageView new];
            image.image = [UIImage imageNamedNoCache:@"icon_data_video_pause.png"];
            [imageView addSubview:image];
            [image mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.center.equalTo(imageView);
            }];
        }
    }else {
        
        imageView.hidden = !(fileCount >= imageIndex + 1);
    }
    
    imageView.userInteractionEnabled = YES;
    imageView.tag = imageIndex;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewClick:)];
    [imageView addGestureRecognizer:tapGesture];
}


-(void)configCellData:(MOUserTaskDataModel *)data {
    
    
    [self.attachmentImagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.timeLabel.text = data.upload_time;
	if (data.location.length > 0) {
		self.dataContentView.locationBtn.hidden = NO;
		[self.dataContentView.locationBtn setTitles:data.location];
	}else {
		self.dataContentView.locationBtn.hidden = YES;
	}
	
    if (data.topic_type == 1) {
		self.dataTitle.attributedText = [MOBaseScheduleCell createTryTagAttributedStringWithTitle:data.task_title.length ? data.task_title:data.idea];
    } else {
        self.dataTitle.attributedText = [MOBaseScheduleCell createNoTryTagAttributedStringWithTitle:data.task_title.length ? data.task_title:data.idea];
    }
    
    self.dataContentView.redDotView.hidden = !data.is_not_read;
    
    UIImageView *fileItem1 = [UIImageView new];
    fileItem1.contentMode = UIViewContentModeScaleAspectFill;
    fileItem1.backgroundColor = ColorEDEEF5;
    [fileItem1 cornerRadius:QYCornerRadiusAll radius:10];
    [self.attachmentImagesView addSubview:fileItem1];
    [fileItem1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.attachmentImagesView.mas_top).offset(0);
        make.left.equalTo(self.attachmentImagesView.mas_left);
        make.width.equalTo(fileItem1.mas_height);
        make.bottom.equalTo(self.attachmentImagesView.mas_bottom).offset(-10);
    }];
    [self configeImageView:fileItem1 imageIndex:0 model:data];
    
    
    
    UIImageView *fileItem2 = [UIImageView new];
    fileItem2.contentMode = UIViewContentModeScaleAspectFill;
    fileItem2.backgroundColor = ColorEDEEF5;
    [fileItem2 cornerRadius:QYCornerRadiusAll radius:10];
    [self.attachmentImagesView addSubview:fileItem2];
    [fileItem2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.attachmentImagesView.mas_top).offset(0);
        make.left.equalTo(fileItem1.mas_right).offset(10);
        make.width.equalTo(fileItem2.mas_height);
        make.width.equalTo(fileItem1.mas_width);
    }];
    [self configeImageView:fileItem2 imageIndex:1 model:data];
    
    UIImageView *fileItem3 = [UIImageView new];
    fileItem3.backgroundColor = ColorEDEEF5;
    fileItem3.contentMode = UIViewContentModeScaleAspectFill;
    [fileItem3 cornerRadius:QYCornerRadiusAll radius:10];
    [self.attachmentImagesView addSubview:fileItem3];
    [fileItem3 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.attachmentImagesView.mas_top).offset(0);
        make.left.equalTo(fileItem2.mas_right).offset(10);
        make.right.equalTo(self.attachmentImagesView.mas_right);
        make.width.equalTo(fileItem3.mas_height);
        make.width.equalTo(fileItem1.mas_width);
    }];
    
    [self configeImageView:fileItem3 imageIndex:2 model:data];
    if (data.result.count > 3) {
        NSString *str = [NSString stringWithFormat:@"+%lu",(unsigned long)(data.result.count - 3)];
        UILabel *lable = [UILabel labelWithText:str textColor:WhiteColor font:MOPingFangSCBoldFont(30)];
        [fileItem3 addSubview:lable];
        [lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(fileItem3);
        }];
    }
    
    if (data.result.count == 1 && data.result.firstObject.data_param.length) {
        [fileItem1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.attachmentImagesView.mas_top).offset(0);
            make.left.equalTo(self.attachmentImagesView.mas_left);
            make.width.equalTo(fileItem1.mas_height);
        }];
        
        NSString *data_paramSTr = StringWithFormat(NSLocalizedString(@"参数：%@", nil),data.result.firstObject.data_param);
        UILabel *data_other_param = [UILabel labelWithText:data_paramSTr textColor:Color828282 font:MOPingFangSCMediumFont(11)];
        [self.attachmentImagesView addSubview:data_other_param];
        [data_other_param mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.top.equalTo(fileItem1.mas_bottom).offset(10);
            make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
            make.bottom.equalTo(self.dataContentView.categoryDataView.mas_bottom).offset(-10);
        }];
        
        
    }
    [self.attachmentImagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
        make.bottom.equalTo(self.dataContentView.categoryDataView.mas_bottom).offset(-10);
    }];
    
}

-(void)previewClick:(UITapGestureRecognizer *)tap {
    NSInteger index =  tap.view.tag;
    if (self.didPreviewClick) {
        self.didPreviewClick(index);
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

-(MOView *)attachmentImagesView {
    
    if (!_attachmentImagesView) {
        _attachmentImagesView = [MOView new];
        
    }
    
    return _attachmentImagesView;
}

@end
