//
//  MOSearchResultCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOSearchResultCell.h"

@interface MOSearchResultCell ()
@property(nonatomic,strong)UILabel *resultTextlabel;
@property(nonatomic,strong)MOButton *addBtn;
@end

@implementation MOSearchResultCell

-(void)addSubViews {
    
    self.contentView.backgroundColor = WhiteColor;
    
    [self.contentView addSubview:self.resultTextlabel];
    [self.resultTextlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView.mas_left).offset(18);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    [self.contentView addSubview:self.addBtn];
    [self.addBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    [self.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.resultTextlabel.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.width.equalTo(@(22));
    }];
}

-(void)addBtnClick {
    
    if (self.didAddBtnClick) {
        self.didAddBtnClick();
    }
}


-(void)configCellWithData:(nullable MOSearchResultCateModel *)data keyword:(nullable NSString *)keyword {
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:data.title?:@"" attributes: @{NSFontAttributeName: MOPingFangSCBoldFont(14),NSForegroundColorAttributeName: Color333333}];
    [string addAttributes:@{NSForegroundColorAttributeName: ColorFF4242} range: [data.title?:@"" rangeOfString:keyword?:@""]];
    
    self.resultTextlabel.attributedText = string;
}


#pragma mark - setter && getter
-(UILabel *)resultTextlabel {
    
    if (!_resultTextlabel) {
        _resultTextlabel = [UILabel new];
    }
    
    return _resultTextlabel;
}

-(MOButton *)addBtn {
    
    if (!_addBtn) {
        _addBtn = [MOButton new];
        [_addBtn setImage:[UIImage imageNamedNoCache:@"icon_searchResult_add.png"]];
//        [_addBtn setImage:[UIImage imageNamedNoCache:@"icon_searchResult_add.png"] forState:UIControlStateDisabled];
//        _addBtn.enabled = NO;
    }
    
    return _addBtn;
}

@end
