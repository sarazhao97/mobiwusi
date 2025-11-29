//
//  MOMyTagSectionHeaderView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/10/5.
//

#import "MOMyTagSectionHeaderView.h"

@interface MOMyTagSectionHeaderView ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation MOMyTagSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
   
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.centerY.equalTo(self);
        make.left.equalTo(self).mas_offset(20);
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imageView);
        make.left.equalTo(self.imageView.mas_right).mas_offset(5.5);
    }];
    
    [self addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imageView);
        make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
    }];
}

- (void)configWithModel:(MOMyTagTypeModel *)model {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.icon_url]];
    self.titleLabel.text = model.name;
    self.numberLabel.text = [NSString stringWithFormat:@"（%d）", model.tags.count];
}

#pragma mark - setter && getter

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

- (UILabel *)numberLabel {
    if (_numberLabel == nil) {
        _numberLabel = [UILabel new];
        _numberLabel.textColor = [UIColor colorWithHexString:@"#B4B4B4"];
        _numberLabel.font = [UIFont systemFontOfSize:13];
    }
    return _numberLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}

@end
