//
//  MOHomeCatCell.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/21.
//

#import "MOHomeCatCell.h"
@interface MOHomeCatCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
@implementation MOHomeCatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
	self.nameLabel.adjustsFontSizeToFitWidth = YES;
	self.nameLabel.minimumScaleFactor = 0.5;
}

- (void)configWithDict:(NSDictionary *)dict {
    self.iconImageView.image = [UIImage imageNamedNoCache:dict[@"icon"]];
    self.nameLabel.text = dict[@"text"];
}

@end
