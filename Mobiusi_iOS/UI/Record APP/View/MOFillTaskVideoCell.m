//
//  MOFillTaskVideoCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import "MOFillTaskVideoCell.h"

@interface MOFillTaskVideoCell ()
@property(nonatomic,strong)MOButton *failureTipIconImageView;
@property(nonatomic,strong)MOView *failureTipcontentView;
@property(nonatomic,strong)UILabel *failureTipTextLabel;
@end

@implementation MOFillTaskVideoCell

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
    
    self.contentView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
    }];
    
    
    [self.contentView addSubview:self.suspendImageView];
    [self.suspendImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.contentView);
    }];
    
    
    [self.contentView addSubview:self.deleteBtn];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contentView.mas_top).offset(4);
        make.right.equalTo(self.contentView.mas_right).offset(-4);
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
        make.right.lessThanOrEqualTo(self.failurePromptView.mas_right);
        make.top.greaterThanOrEqualTo(self.failurePromptView.mas_top);
        make.bottom.lessThanOrEqualTo(self.failurePromptView.mas_bottom);
        make.width.greaterThanOrEqualTo(@(18));
    }];
    
    [self.failureTipcontentView addSubview:self.failureTipTextLabel];
    [self.failureTipcontentView addSubview:self.failureTipIconImageView];
    
    
    [self.failureTipTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.failureTipcontentView.mas_centerX);
        make.top.equalTo(self.failureTipIconImageView.mas_bottom).offset(2);
        make.bottom.equalTo(self.failureTipcontentView.mas_bottom);
        make.left.equalTo(self.failureTipcontentView.mas_left);
        make.right.equalTo(self.failureTipcontentView.mas_right);
    }];
    
    
    [self.failureTipIconImageView addTarget:self action:@selector(errorImageClick) forControlEvents:UIControlEventTouchUpInside];
    [self.failureTipIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.failureTipcontentView.mas_top);
        make.centerX.equalTo(self.failureTipcontentView.mas_centerX);
        make.height.width.equalTo(@(18));
    }];
    
    
}


-(void)configImageCellWithModel:(MOAttchmentImageFileInfoModel *)model {
    
    self.suspendImageView.hidden = YES;
    if (model.image) {
        self.imageView.image = model.image;
    } else {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.fileServerUrl]];
    }
    self.failurePromptView.hidden = !(model.fileStatus == 3);
    self.failureTipTextLabel.text = model.errorMsg;
    
}

-(void)configVideoCellWithModel:(MOAttchmentVideoFileInfoModel *)model {
    
    if (model.thumbnail) {
        self.imageView.image = model.thumbnail;
    } else {
        WEAKSELF
        [self getVideoThumbnailFromURL:[NSURL URLWithString:model.fileServerUrl?:@""] completion:^(UIImage *thumbnail) {
            dispatch_main_async_safe(^{
                weakSelf.imageView.image = thumbnail;
                model.thumbnail = thumbnail;
            });
            
        }];
        
    }
    
    self.failureTipTextLabel.text = model.errorMsg;
}

-(void)getVideoThumbnailFromURL:(NSURL *)videoURL completion:(void (^)(UIImage *thumbnail))completion {
    // 创建AVAsset对象
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    // 创建AVAssetImageGenerator对象
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    // 应用首选的轨道变换，确保缩略图方向正确
    imageGenerator.appliesPreferredTrackTransform = YES;

    // 定义要获取缩略图的时间点，这里是视频开始的时间（0秒）
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    // 开始异步生成缩略图
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image) {
            // 如果生成成功，将CGImageRef转换为UIImage
            UIImage *thumbnail = [UIImage imageWithCGImage:image];
            // 调用完成回调，传递缩略图
            completion(thumbnail);
        } else {
            // 如果生成失败，调用完成回调，传递nil
            completion(nil);
            if (error) {
                DLog(@"获取缩略图失败: %@", error.localizedDescription);
            }
        }
    }];
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
-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        [_imageView cornerRadius:QYCornerRadiusAll radius:10];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

-(MOButton *)deleteBtn {
    
    if (!_deleteBtn) {
        _deleteBtn = [MOButton new];
        [_deleteBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
        [_deleteBtn setImage:[UIImage imageNamedNoCache:@"incon_data_video_delete.png"]];
        
    }
    return _deleteBtn;
}

-(UIImageView *)suspendImageView {
    
    if (!_suspendImageView) {
        _suspendImageView = [UIImageView new];
        _suspendImageView.image = [UIImage imageNamedNoCache:@"icon_data_video_pause.png"];
    }
    return _suspendImageView;
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
        _failureTipTextLabel.numberOfLines = 0;
    }
    
    return _failureTipTextLabel;
}

@end
