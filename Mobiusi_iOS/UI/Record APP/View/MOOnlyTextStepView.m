//
//  MOOnlyTextStepView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOOnlyTextStepView.h"
#import <UITextView+ZWPlaceHolder.h>

@implementation MOOnlyTextStepView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(21);
        make.top.equalTo(self.mas_top).offset(10);
    }];
    
    
//    [self addSubview:self.exampleBtn];
//    [self.exampleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.right.equalTo(self.mas_right).offset(-28);
//        make.centerY.equalTo(self.titleLabel.mas_centerY);
//    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(11);
        make.right.equalTo(self.mas_right).offset(-11);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.bottom.equalTo(self.mas_bottom).offset(10);
        
    }];
    
    
    [self.contentView addSubview:self.textInput];
    self.textInput.zw_placeHolder = NSLocalizedString(@"输入文本内容", nil);
    self.textInput.zw_placeHolderColor = [BlackColor colorWithAlphaComponent:0.3];
    [self.textInput mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(21);
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.right.equalTo(self.contentView.mas_right).offset(-17);
        make.height.equalTo(@(100));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
    }];
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (object == self.textInput) {
        
        CGSize size = [change[@"new"] CGSizeValue];
        if (size.height > 100) {
            [self.textInput mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(self.contentView.mas_left).offset(21);
                make.top.equalTo(self.contentView.mas_top).offset(20);
                make.right.equalTo(self.contentView.mas_right).offset(-17);
                make.height.equalTo(@(size.height));
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
            }];
        } else {
            
            [self.textInput mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(self.contentView.mas_left).offset(21);
                make.top.equalTo(self.contentView.mas_top).offset(20);
                make.right.equalTo(self.contentView.mas_right).offset(-17);
                make.height.equalTo(@(100));
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-23);
            }];
            
        }
        
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
        _titleLabel = [UILabel labelWithText:NSLocalizedString(@"Step2：输入文本内容", nil) textColor:Color626262 font:MOPingFangSCMediumFont(12)];
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


-(UITextView *)textInput {
    
    if (!_textInput) {
        _textInput = [UITextView new];
        _textInput.textColor = BlackColor;
        _textInput.font = MOPingFangSCMediumFont(12);
        _textInput.showsVerticalScrollIndicator = NO;
        [_textInput addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    
    return _textInput;
}


@end
