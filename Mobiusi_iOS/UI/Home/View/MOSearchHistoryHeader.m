//
//  MOSearchHistoryHeader.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOSearchHistoryHeader.h"

@interface MOSearchHistoryHeader ()

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOButton *clearBtn;
@property(nonatomic,strong)MOView *contentView;
@end

@implementation MOSearchHistoryHeader


-(void)addSubViewsInFrame:(CGRect)frame {
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(26));
        make.top.equalTo(self.mas_top).offset(21);
        
    }];
    
    
    [self addSubview:self.clearBtn];
    [self.clearBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-10);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        
    }];
    
    [self addSubview:self.contentView];
    CGFloat height = [self layoutButtons];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.mas_right).offset(-26);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.height.equalTo(@(height));
        make.bottom.equalTo(self.mas_bottom).offset(-24);
    }];
    
}

- (CGFloat)layoutButtons {
    CGFloat buttonMargin = 10;
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat btnHeight = 27.0;
    CGFloat maxY = 0;
    NSInteger lineCount = 0;
//    NSArray *buttonTitles = @[@"洛阳方言",@"街景",@"方圆创世",@"墨比乌斯",@"宝马",@"二七塔",@"郑州方言",@"洛阳方言",@"小米汽车",@"小米",@"金水区",@"郑开大道",@"开封方言",@"郑州方言"];
    NSArray *buttonTitles =   [[NSUserDefaults standardUserDefaults] objectForKey:SearchHistoryList];
    for (NSString *title in buttonTitles) {
        // 创建按钮
        UIButton *button = [MOButton new];
        [button setTitle:title titleColor:Color333333 bgColor:WhiteColor font:MOPingFangSCMediumFont(12)];
        [button cornerRadius:QYCornerRadiusAll radius:100];
        [button addTarget:self action:@selector(historyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
        [button sizeToFit];
        
        
        // 检查是否超过最大宽度
        if (currentX + button.frame.size.width + buttonMargin > SCREEN_WIDTH - 26*2) {
            currentX = 0;
            currentY = maxY + buttonMargin;
            lineCount++;
            if (lineCount >= 3) {
                maxY = MAX(maxY, CGRectGetMaxY(button.frame));
                break;
            }
        }
        
        button.frame = CGRectMake(currentX, currentY, button.frame.size.width , btnHeight);
        [self.contentView addSubview:button];
        // 计算下一个按钮的位置X
        currentX += button.frame.size.width + buttonMargin;
        maxY = MAX(maxY, CGRectGetMaxY(button.frame));
    }
    
    return  maxY;
}


-(void)historyBtnClick:(MOButton *)btn {
    
    if (self.didSelectHistorySearch) {
        self.didSelectHistorySearch(btn.titleLabel.text);
    }
}

-(void)clearBtnClick {
    
    if (self.didClearHistorySearch) {
        self.didClearHistorySearch();
    }
}


#pragma mark - setter && getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:NSLocalizedString(@"历史搜索", nil) textColor:ColorAFAFAF font:MOPingFangSCMediumFont(13)];
    }
    return _titleLabel;
}

-(MOButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [MOButton new];
        [_clearBtn setImage:[UIImage imageNamedNoCache:@"icon_search_clear.png"]];
        [_clearBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _clearBtn;
}

-(MOView *)contentView {
    
    if (!_contentView) {
        _contentView = [MOView new];
    }
    
    return _contentView;
}

@end
