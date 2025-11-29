//
//  MOTextFillTaskUploadFileCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOTextFillTaskUploadFileCell.h"

@interface MOTextFillTaskUploadFileCell ()
@property(nonatomic,strong)MOButton *failureTipIconImageView;
@property(nonatomic,strong)MOView *failureTipcontentView;
@property(nonatomic,strong)UILabel *failureTipTextLabel;
@end

@implementation MOTextFillTaskUploadFileCell
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
    
    
    [self.contentView addSubview:self.fileView];
    [self.fileView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
    }];
    
    
    
    [self.contentView addSubview:self.deleteBtn];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.contentView.mas_right).offset(-12);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.contentView addSubview:self.failurePromptView];
    [self.failurePromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
    }];
    
    [self.failurePromptView addSubview:self.failureTipcontentView];
    [self.failureTipcontentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.failurePromptView.mas_centerY);
        make.centerX.equalTo(self.failurePromptView.mas_centerX);
        make.left.greaterThanOrEqualTo(self.failurePromptView.mas_left);
        make.left.lessThanOrEqualTo(self.failurePromptView.mas_right);
    }];
    
    [self.failureTipcontentView addSubview:self.failureTipTextLabel];
    [self.failureTipTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.failureTipcontentView.mas_centerY);
        make.right.equalTo(self.failureTipcontentView.mas_right);
    }];
    
    [self.failureTipcontentView addSubview:self.failureTipIconImageView];
    
    [self.failureTipIconImageView addTarget:self action:@selector(errorImageClick) forControlEvents:UIControlEventTouchUpInside];
    [self.failureTipIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.failureTipcontentView.mas_top);
        make.bottom.equalTo(self.failureTipcontentView.mas_bottom);
        make.right.equalTo(self.failureTipTextLabel.mas_left).offset(-3);
        make.left.equalTo(self.failureTipcontentView.mas_left);
        make.height.width.equalTo(@(18));
    }];
    
    
}

-(void)configCellWithModel:(MOAttchmentFileInfoModel *)model {
    self.fileView.fileNameLabel.text = model.fileName;
    self.deleteBtn.hidden = !(model.fileStatus == 0);
    self.failurePromptView.hidden = !(model.fileStatus == 3);
    self.failureTipTextLabel.text = model.errorMsg;
    
}

-(void)deleteBtnClick {
    
    if (self.didDeleteBtnClick) {
        self.didDeleteBtnClick();
    }
}

-(void)errorImageClick {
    
    if (self.didErrorIconClick) {
        self.didErrorIconClick();
    }
}

#pragma mark - setter && getter
-(MODocFileItemView *)fileView {
    
    if (!_fileView) {
        _fileView = [MODocFileItemView new];
        _fileView.backgroundColor = ColorEDEEF5;
        [_fileView cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _fileView;
}


-(MOButton *)deleteBtn {
    
    if (!_deleteBtn) {
        _deleteBtn = [MOButton new];
        [_deleteBtn setImage:[UIImage imageNamedNoCache:@"icon_popup_close_gray.png"]];
        [_deleteBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _deleteBtn;
}

-(MOView *)failurePromptView {
    
    if (!_failurePromptView) {
        _failurePromptView = [MOView new];
        _failurePromptView.backgroundColor = [BlackColor colorWithAlphaComponent:0.6];
        [_failurePromptView cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _failurePromptView;
}


-(MOView *)failureTipcontentView {
    
    if (!_failureTipcontentView) {
        _failureTipcontentView = [MOView new];
    }
    return _failureTipcontentView;
}


-(MOButton *)failureTipIconImageView {
    if (!_failureTipIconImageView) {
        _failureTipIconImageView = [MOButton new];
        [_failureTipIconImageView setImage:[UIImage imageNamedNoCache:@"icon_data_file_error.png"]];
        [_failureTipIconImageView setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _failureTipIconImageView;
}
-(UILabel *)failureTipTextLabel {
    
    if (!_failureTipTextLabel) {
        _failureTipTextLabel = [UILabel labelWithText:@"" textColor:WhiteColor font:MOPingFangSCMediumFont(10)];
    }
    
    return _failureTipTextLabel;
}

@end
