//
//  MOTextFillTaskStep2View.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOTextFillTaskStep2View.h"
#import <UITextView+ZWPlaceHolder.h>



@interface MOTextFillTaskStep2View ()<UIDocumentInteractionControllerDelegate>
@end

@implementation MOTextFillTaskStep2View


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
    
    
}

-(void)exampleBtnClick {
    
    if (self.didExampleBtnClick) {
        self.didExampleBtnClick();
    }
}

-(UIView *)bottomView {
    
    return nil;
}

-(void)configUIWithModel:(MOTaskListModel *)model {

    self.exampleBtn.hidden = [model.example_url length] == 0;
    if (model.is_need_describe) {
        if (!self.textInput) {
            
            self.textInput = [UITextView new];
            self.textInput.textColor = BlackColor;
            self.textInput.font = MOPingFangSCMediumFont(12);
            self.textInput.showsVerticalScrollIndicator = NO;
            [self.textInput addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        }
    }
    
    if (model.limit_of_one_upload_file > 0) {
       
        if (!self.attchmentCollectionView) {
            UICollectionViewFlowLayout *flowly = [UICollectionViewFlowLayout new];
            flowly.itemSize = CGSizeMake(SCREEN_WIDTH - 29 - 25, 35);
            self.attchmentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10) collectionViewLayout:flowly];
            self.attchmentCollectionView.scrollEnabled = NO;
            [self.attchmentCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            self.attchmentCollectionView.backgroundColor = ClearColor;
        }
        
    }
    
    
    
    [self.contentView addSubview:self.textInput];
    
    self.textInput.zw_placeHolder = NSLocalizedString(@"请输入文本内容...", nil);
    self.textInput.zw_placeHolderColor = [BlackColor colorWithAlphaComponent:0.3];
    [self.textInput mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(21);
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.height.equalTo(@(232));
        if (!self.attchmentCollectionView) {
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
        }
        
    }];
    
    
    [self.contentView addSubview:self.attchmentCollectionView];
    [self.attchmentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(21);
        if (self.textInput) {
            make.top.equalTo(self.textInput.mas_bottom).offset(16);
        } else{
            make.top.equalTo(self.contentView.mas_top).offset(20);
        }
        
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (object == self.attchmentCollectionView) {
        CGSize size = [change[@"new"] CGSizeValue];
        [self.attchmentCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(21);
            if (self.textInput) {
                make.top.equalTo(self.textInput.mas_bottom).offset(16);
            } else{
                make.top.equalTo(self.contentView.mas_top).offset(20);
            }
            make.right.equalTo(self.contentView.mas_right).offset(-17);
            make.height.equalTo(@(size.height));
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
        }];
    }
    
    if (object == self.textInput) {
        
        CGSize size = [change[@"new"] CGSizeValue];
        CGFloat height = size.height > 232?:232;
        [self.textInput mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.contentView.mas_left).offset(21);
            make.top.equalTo(self.contentView.mas_top).offset(20);
            make.right.equalTo(self.contentView.mas_right).offset(-17);
            make.height.equalTo(@(height));
            if (!self.attchmentCollectionView) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
            }
        }];
        
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
        _titleLabel = [UILabel labelWithText:NSLocalizedString(@"Step2：输入或上传文本", nil) textColor:Color626262 font:MOPingFangSCMediumFont(12)];
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


@end
