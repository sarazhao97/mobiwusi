//
//  MORecordTaskAlertView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/16.
//

#import "MORecordTaskAlertView.h"

@interface MORecordTaskAlertView ()

@property (weak, nonatomic) IBOutlet UITextView *descTv;

@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@end

@implementation MORecordTaskAlertView

-(void)awakeFromNib {
    [super awakeFromNib];
    self.bottomBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.bottomBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bottomBtn.titleLabel.minimumScaleFactor = 0.6;
}

- (void)setTaskRequirement:(NSString *)requirement {
    self.descTv.text = requirement;
}

- (IBAction)agreeClick:(id)sender {
    self.hidden = YES;
}

- (IBAction)closeClick:(id)sender {
    self.hidden = YES;
}

@end
