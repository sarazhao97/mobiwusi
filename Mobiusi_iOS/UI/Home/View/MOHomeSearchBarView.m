//
//  MOHomeSearchBarView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOHomeSearchBarView.h"

@implementation MOHomeSearchBarView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    self.contentView = [MOView new];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(11));
        make.right.equalTo(@(-11));
        make.bottom.equalTo(@(-2));
        make.top.equalTo(@(2));
        
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldClick)];
    [self.contentView addGestureRecognizer:tapGesture];
    [self.contentView cornerRadius:QYCornerRadiusAll radius:12 borderWidth:4 borderColor:MainSelectColor];
    
    self.leftIconImageView = [UIImageView new];
    self.leftIconImageView.image = [UIImage imageNamedNoCache:@"icon_home_search.png"];
    [self.contentView addSubview:self.leftIconImageView];
    [self.leftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(19));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.equalTo(@(15));
        
    }];
    [self.leftIconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.searchTF = [UITextField new];
    self.searchTF.enabled = NO;
    self.searchTF.font = MOPingFangSCFont(12);
    self.searchTF.placeholder = NSLocalizedString(@"输入关键字/项目ID搜索", nil);
    
    [self.contentView addSubview:self.searchTF];
    [self.searchTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftIconImageView.mas_right).offset(8);
        make.top.equalTo(@(2));
        make.bottom.equalTo(@(-2));
    }];
    
    self.searchBtn = [MOButton new];
    //修复不居中的BUG
    self.searchBtn.imageAlignment = MOButtonImageAlignmentBottom + 1;
    self.searchBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
    [self.contentView addSubview:self.searchBtn];
    [self.searchBtn setTitle:StringWithFormat(@"%@",NSLocalizedString(@"搜索", nil)) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCFont(12)];
    [self.searchBtn cornerRadius:QYCornerRadiusAll radius:10];
    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchTF.mas_right);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@(26));
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
}

-(void)textFieldClick {
    
    if (self.didSearch) {
        self.didSearch();
    }
}

-(void)searchBtnClick {
    if (self.didSearch) {
        self.didSearch();
    }
}
@end
