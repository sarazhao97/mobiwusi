//
//  MOPictureVideoStep2PlaceholderCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOPictureVideoStep2PlaceholderCell.h"

@implementation MOPictureVideoStep2PlaceholderCell


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 14.0, *)) {
            self.backgroundConfiguration = [UIBackgroundConfiguration clearConfiguration];
        }
        [self addSubviews];
    }
    
    return self;
}

-(void)addSubviews {
    
    
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.contentView);
    }];
    
    
    
    [self.bgView addSubview:self.centerImageView];
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgView);
    }];
    
}


#pragma mark - setter && getter

-(MOView *)bgView {
    if (!_bgView) {
        _bgView = [MOView new];
        _bgView.backgroundColor = ColorEDEEF5;
        [_bgView cornerRadius:QYCornerRadiusAll radius:10];
    }
    return _bgView;
}

-(UIImageView *)centerImageView {
    
    if (!_centerImageView) {
        _centerImageView = [UIImageView new];
        _centerImageView.image = [UIImage imageNamedNoCache:@"icon_data_image_add.png"];
        _centerImageView.contentMode = UIViewContentModeCenter;
    }
    return _centerImageView;
}


@end
