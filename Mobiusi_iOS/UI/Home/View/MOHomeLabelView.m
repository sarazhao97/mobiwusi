//
//  MOHomeLabelView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/29.
//

#import "MOHomeLabelView.h"

@interface MOHomeLabelView ()
@property (weak, nonatomic) IBOutlet UILabel *ownLabelCount;
@property (weak, nonatomic) IBOutlet UILabel *addLabelCount;
@property (weak, nonatomic) IBOutlet UILabel *notHaveLabelCount;

@end

@implementation MOHomeLabelView

- (void)reloadLabelCountWithUser:(MOUserModel *)user {
    self.ownLabelCount.text = [NSString stringWithFormat:@"%d", user.has_tag_count];
    self.notHaveLabelCount.text = [NSString stringWithFormat:@"%d", user.no_tag_count];
    if (user.has_tag_count_recently > 1) {
        self.addLabelCount.text = [NSString stringWithFormat:@"+%d", user.has_tag_count_recently];
    } else {
        self.addLabelCount.text = @"";
    }
}

@end
