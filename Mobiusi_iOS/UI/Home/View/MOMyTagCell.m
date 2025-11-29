//
//  MOMyTagCell.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/12.
//

#import "MOMyTagCell.h"

@interface MOMyTagCell ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;

@end

@implementation MOMyTagCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configWithModel:(MOMyTagModel *)model {
    self.bgView.backgroundColor = [UIColor colorWithHexString:model.bg_color];
    self.tagNameLabel.textColor = [UIColor colorWithHexString:model.font_color];
    self.tagNameLabel.text = model.name;
}

@end
