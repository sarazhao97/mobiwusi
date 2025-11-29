//
//  MOSearchNavBarView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "MOSearchNavBarView.h"


@interface MOSearchNavBarView ()<UITextFieldDelegate>

@end

@implementation MOSearchNavBarView

-(void)addSubViewsInFrame:(CGRect)frame {
    
    self.backBtn = [MOButton new];
    [self.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    [self.backBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    [self.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backBtn];
    
    
    self.searchContnetView = [MOView new];
    self.searchContnetView.backgroundColor = WhiteColor;
    [self.searchContnetView cornerRadius:QYCornerRadiusAll radius:16];
    [self addSubview:self.searchContnetView];
    [self.searchContnetView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.equalTo(@(40));
        make.top.equalTo(@(2));
        make.bottom.equalTo(@(-2));
        make.left.equalTo(self.backBtn.mas_right).offset(8);
        make.right.equalTo(self.mas_right).offset(-11);
    }];
    
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.equalTo(@(24));
        make.left.equalTo(@(10));
        make.centerY.equalTo(self.searchContnetView.mas_centerY);
    }];
    
    self.searchTF = [UITextField new];
    self.searchTF.font = MOPingFangSCFont(14.0);
    self.searchTF.placeholder = NSLocalizedString(@"输入关键字搜索",nil);;
    self.searchTF.delegate = self;
    self.searchTF.clearButtonMode = UITextFieldViewModeUnlessEditing;
    [self.searchContnetView addSubview:self.searchTF];
    WEAKSELF
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        if (weakSelf.searchTF == notification.object) {
            if (![weakSelf.searchTF.text  length]) {
                if (weakSelf.didDeleteAllSearchTFText) {
                    weakSelf.didDeleteAllSearchTFText(weakSelf.searchTF);
                }
            }
        }
    }];
    [self.searchTF mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(16));
        make.centerY.equalTo(self.searchContnetView.mas_centerY);
    }];
    
    self.searchBtn = [MOButton new];
    //修复不居中的BUG
    self.searchBtn.imageAlignment = MOButtonImageAlignmentBottom + 1;
    self.searchBtn.titleLabel.textAlignment = NSTextAlignmentNatural;
    [self.searchBtn setTitle:StringWithFormat(@"%@",NSLocalizedString(@"搜索", nil)) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCFont(12)];
    [self.searchBtn cornerRadius:QYCornerRadiusAll radius:10];
    [self.searchContnetView addSubview:self.searchBtn];
    [self.searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.searchTF.mas_right).offset(10);
        make.right.equalTo(self.searchContnetView.mas_right).offset(-7);
        make.centerY.equalTo(self.searchContnetView.mas_centerY);
        make.height.equalTo(@(26));
        
    }];
    
}

-(void)goBack{
    
    if (self.gobackDidClick) {
        self.gobackDidClick();
    }
}

-(void)searchBtnClick {
    
    if ([self.searchTF.text length]) {
        
        if (self.didSearch) {
            self.didSearch(self.searchTF.text,self.searchTF);
        }
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.searchTF.text length]) {
        
        if (self.didSearch) {
            self.didSearch(self.searchTF.text,self.searchTF);
        }
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    return YES;
}
@end
