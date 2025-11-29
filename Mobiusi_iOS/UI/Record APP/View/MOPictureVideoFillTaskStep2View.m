//
//  MOPictureVideoFillTaskStep2View.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOPictureVideoFillTaskStep2View.h"

@implementation MOPictureVideoFillTaskStep2View


-(void)addSubViewsInFrame:(CGRect)frame {
    
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(21);
        make.top.equalTo(self.mas_top).offset(10);
    }];
    
    
    [self addSubview:self.exampleBtn];
    [self.exampleBtn addTarget:self action:@selector(exampleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.exampleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-28);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
    }];
    
    [self addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(11);
        make.right.equalTo(self.mas_right).offset(-11);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.bottom.equalTo(self.mas_bottom).offset(10);
        
    }];
    
    
    
    [self.contentView addSubview:self.pictureVideoCollectionView];
    [self.pictureVideoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(21);
        make.top.equalTo(self.contentView.mas_top).offset(16);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    DLog(@"%@",change);
    if (object == self.pictureVideoCollectionView) {
        CGSize size = [change[@"new"] CGSizeValue];
        [self.pictureVideoCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(21);
            make.top.equalTo(self.contentView.mas_top).offset(16);
            make.right.equalTo(self.contentView.mas_right).offset(-17);
            make.height.equalTo(@(size.height));
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
        }];
    }
    
}

-(void)exampleBtnClick {
    
    if (self.didExampleBtnClick) {
        self.didExampleBtnClick();
    }
}


#pragma mark - setter && getter
-(MOView *)contentView {
    
    if (!_contentView) {
        _contentView = [MOView new];
        _contentView.backgroundColor = WhiteColor;
        [_contentView cornerRadius:QYCornerRadiusAll radius:20];
    }
    return _contentView;
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:NSLocalizedString(@"Step2：开始拍摄或上传视频和图片", nil) textColor:Color626262 font:MOPingFangSCMediumFont(12)];
    }
    return _titleLabel;
}

-(MOButton *)exampleBtn {
    
    if (!_exampleBtn) {
        _exampleBtn = [MOButton new];
        [_exampleBtn setTitle:NSLocalizedString(@"样例", nil) titleColor:Color34C759 bgColor:ClearColor font:MOPingFangSCBoldFont(12)];
        [_exampleBtn setImage:[UIImage imageNamedNoCache:@"icon_data_light_bulb.png"]];
    }
    
    return _exampleBtn;
}


-(UICollectionView *)pictureVideoCollectionView {
    
    
    if (!_pictureVideoCollectionView) {
        
        UICollectionViewFlowLayout *flowly = [UICollectionViewFlowLayout new];
        CGFloat itemMagrin = 10;
        CGFloat scrollContentViewMargin = 11;
        CGFloat pictureVideoCollectionViewLeftMargin = 21;
        CGFloat pictureVideoCollectionViewRightMargin = 17;
        CGFloat width = (SCREEN_WIDTH - pictureVideoCollectionViewLeftMargin - pictureVideoCollectionViewRightMargin - 2*scrollContentViewMargin - 2*itemMagrin)/3.0;
        flowly.itemSize = CGSizeMake(width, width);
        flowly.minimumInteritemSpacing = itemMagrin;
        _pictureVideoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10) collectionViewLayout:flowly];
        _pictureVideoCollectionView.scrollEnabled = NO;
        [_pictureVideoCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        _pictureVideoCollectionView.backgroundColor = ClearColor;
    }
    
    return _pictureVideoCollectionView;
}

@end
