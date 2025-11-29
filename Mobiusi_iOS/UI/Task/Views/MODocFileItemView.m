//
//  MODocFileItemView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MODocFileItemView.h"

@implementation MODocFileItemView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    
    [self addSubview:self.fileIconImageView];
    [self.fileIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@12);
        make.centerY.equalTo(self.mas_centerY);
    }];
    [self.fileIconImageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self addSubview:self.fileNameLabel];
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.fileIconImageView.mas_right).offset(7);
        make.right.equalTo(self.mas_right).offset(-7);
        make.centerY.equalTo(self.mas_centerY);
    }];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	// 设置点击次数和手指数
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.numberOfTouchesRequired = 1;
	
	[self addGestureRecognizer:tapGesture];
	
    
}


- (void)handleTap:(UITapGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateRecognized) {
		if (self.didCilck) {
			self.didCilck();
		}
	}
}

-(UIImageView *)fileIconImageView {
    
    if (!_fileIconImageView) {
        _fileIconImageView = [UIImageView new];
        _fileIconImageView.image = [UIImage imageNamedNoCache:@"icon_data_text_doc.png"];
    }
    return _fileIconImageView;
}

-(UILabel *)fileNameLabel {
    
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel labelWithText:@"" textColor:Color333333 font:MOPingFangSCMediumFont(12)];
    }
    
    return _fileNameLabel;
}
@end
