//
//  MOHomeTaskCell.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/29.
//

#import "MOHomeTaskCell.h"
#import "MOTaskTagView.h"

@interface MOHomeTaskCell ()
@property (weak, nonatomic) IBOutlet UILabel *taskTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *midLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *tryLabel;
@property (weak, nonatomic) IBOutlet UIView *TryLableView;

@property (weak, nonatomic) IBOutlet UIView *tryBgView;
@property (weak, nonatomic) IBOutlet UILabel *tryNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *participateNumLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IdLabelX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelRight;

@end

@implementation MOHomeTaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configMyTaskCellWithModel:(MOTaskListModel *)model {
    self.taskTitleLabel.text = model.title;
    self.descLabel.text = model.simple_descri;
    
    BOOL showTryView = YES;
    if (model.is_try == 0) {
        // 任务为不需要试做时 获取正式题目
        showTryView = NO;
    } else if (model.is_try == 1 && model.try_status == 1) {
        // 任务为需要试做且试做通过时 获取正式题目
        showTryView = NO;
    } else {
        // 其他都加载试做题目
        showTryView = YES;
    }
    
    if (showTryView == YES) {
        self.tryBgView.hidden = NO;
        self.tryLabel.text = NSLocalizedString(@"测试数据",nil);
        self.TryLableView.backgroundColor = [UIColor colorWithHexString:@"#FC9E09"];
        self.tryNumLabel.textColor = [UIColor colorWithHexString:@"#FC9E09"];
        self.tryBgView.backgroundColor = [UIColor colorWithHexString:@"#FC9E09" alpha:0.2];
        
        NSString *tryNumStr = [NSString stringWithFormat:NSLocalizedString(@"%ld条", nil), (long)model.try_topic_num];
        self.tryNumLabel.text = tryNumStr;
        CGFloat width1 = [Util calculateLabelSizeWithText:NSLocalizedString(@"测试数据",nil) andMarginSize:CGSizeMake(CGFLOAT_MAX, 14) andTextFont:[UIFont systemFontOfSize:10]].width;
        CGFloat width2 = [Util calculateLabelSizeWithText:tryNumStr andMarginSize:CGSizeMake(CGFLOAT_MAX, 14) andTextFont:[UIFont systemFontOfSize:10]].width;
        self.IdLabelX.constant = 18+8+width1+8+width2+5;
        self.midLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PoID:%@ 已完成%d 共%d", nil), model.task_no, model.try_finished, model.try_topic_num];

    } else {
        self.tryBgView.hidden = NO;
        self.tryLabel.text = NSLocalizedString(@"正式数据",nil);
        self.TryLableView.backgroundColor = MainSelectColor;
        self.tryNumLabel.textColor = MainSelectColor;
        self.tryBgView.backgroundColor = [UIColor colorWithHexString:@"#9A1E2E" alpha:0.2];

        NSString *tryNumStr = [NSString stringWithFormat:NSLocalizedString(@"%ld条", nil), (long)model.topic_num];
        self.tryNumLabel.text = tryNumStr;
        CGFloat width1 = [Util calculateLabelSizeWithText:NSLocalizedString(@"正式数据",nil) andMarginSize:CGSizeMake(CGFLOAT_MAX, 14) andTextFont:[UIFont systemFontOfSize:10]].width;
        CGFloat width2 = [Util calculateLabelSizeWithText:tryNumStr andMarginSize:CGSizeMake(CGFLOAT_MAX, 14) andTextFont:[UIFont systemFontOfSize:10]].width;
        self.IdLabelX.constant = 18+8+width1+8+width2+5;
        self.midLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PoID:%@ 已完成%d 共%d", nil), model.task_no, model.finished, model.topic_num];

    }
    
    if (model.price.isExist && [model.price floatValue] > 0) {
        NSMutableAttributedString *currency_unit = [NSMutableAttributedString createWithString:model.currency_unit?:@"" font:[UIFont boldSystemFontOfSize:12] textColor:MainSelectColor];
        NSMutableAttributedString *price = [NSMutableAttributedString createWithString:model.price?:@"" font:[UIFont boldSystemFontOfSize:20] textColor:MainSelectColor];
        NSMutableAttributedString *unit = [NSMutableAttributedString createWithString:model.unit?:@"" font:[UIFont boldSystemFontOfSize:12] textColor:MainSelectColor];

        
        [currency_unit appendAttributedString:price];
        [currency_unit appendAttributedString:unit];
        self.priceLabel.text = nil;
        self.priceLabel.attributedText = currency_unit;
    } else {
        self.priceLabel.text = @"";
    }
    
    ///参与人数
    NSInteger user_task_num = model.user_task_num;
    NSString *task_num_str = @"";
    NSString *participateInStr =  [NSString numberOfPeopleToStringWithUnit:user_task_num];
    task_num_str = [NSString stringWithFormat:NSLocalizedString(@"%@人参与", nil), participateInStr];
    
    self.participateNumLabel.text = task_num_str;
    
    self.titleLabelRight.constant = [Util calculateLabelSizeWithText:task_num_str andMarginSize:CGSizeMake(SCREEN_WIDTH, 14) andTextFont:[UIFont systemFontOfSize:11]].width+40;
}

- (void)configHomeCellWithModel:(MOTaskListModel *)model {
    self.taskTitleLabel.text = model.title;
    self.descLabel.text = model.simple_descri;
   
    self.tryBgView.hidden = YES;
    self.IdLabelX.constant = 18;
    
    self.midLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PoID:%@", nil), model.task_no];
    
    if (model.price.isExist && [model.price floatValue] > 0) {
        NSMutableAttributedString *currency_unit = [NSMutableAttributedString createWithString:model.currency_unit?:@"" font:[UIFont boldSystemFontOfSize:12] textColor:MainSelectColor];
        NSMutableAttributedString *price = [NSMutableAttributedString createWithString:model.price?:@"" font:[UIFont boldSystemFontOfSize:20] textColor:MainSelectColor];
        NSMutableAttributedString *unit = [NSMutableAttributedString createWithString:model.unit?:@"" font:[UIFont boldSystemFontOfSize:12] textColor:MainSelectColor];

        [currency_unit appendAttributedString:price];
        [currency_unit appendAttributedString:unit];
        self.priceLabel.text = nil;
        self.priceLabel.attributedText = currency_unit;
    } else {
        self.priceLabel.text = @"";
    }
    
    ///参与人数
    NSInteger user_task_num = model.user_task_num;
    NSString *task_num_str = @"";
    NSString *participateInStr =  [NSString numberOfPeopleToStringWithUnit:user_task_num];
    task_num_str = [NSString stringWithFormat:NSLocalizedString(@"%@人参与", nil), participateInStr];
    
    task_num_str = [NSString stringWithFormat:NSLocalizedString(@"剩%d名额/%d", nil), model.remaining_places,model.person_limit];
    self.participateNumLabel.text = task_num_str;
    
    self.titleLabelRight.constant = [Util calculateLabelSizeWithText:task_num_str andMarginSize:CGSizeMake(SCREEN_WIDTH, 14) andTextFont:[UIFont systemFontOfSize:11]].width+40;
}

@end
