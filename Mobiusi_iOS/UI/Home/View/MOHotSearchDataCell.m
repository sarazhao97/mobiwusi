//
//  MOHotSearchDataCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOHotSearchDataCell.h"

@interface MOHotSearchDataCell ()

@end

@implementation MOHotSearchDataCell

- (void)addSubViews {
    
    self.contentView.backgroundColor = WhiteColor;
    [self.contentView addSubview:self.indexLabel];
    [self.indexLabel cornerRadius:QYCornerRadiusAll radius:3];
    [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.equalTo(@(14));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@(14));
        make.height.equalTo(@(14));
        
    }];
    [self.indexLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    
    [self.contentView addSubview:self.searchTextLabel];
    [self.searchTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.left.equalTo(self.indexLabel.mas_right).offset(7);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-7);
        
    }];
}


#pragma mark - setter && getter
-(UILabel *)indexLabel {
    
    if (!_indexLabel) {
        _indexLabel = [UILabel labelWithText:@"1" textColor:WhiteColor font:MOPingFangSCFont(12)];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _indexLabel;
}

-(UILabel *)searchTextLabel {
    
    if (!_searchTextLabel) {
        _searchTextLabel = [UILabel labelWithText:@"郑州夜骑开封" textColor:Color333333 font:MOPingFangSCBoldFont(14)];
    }
    
    return _searchTextLabel;
}
@end
