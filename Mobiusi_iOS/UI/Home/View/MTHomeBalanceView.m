//
//  MTHomeBalanceView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/8/21.
//

#import "MTHomeBalanceView.h"

@interface MTHomeBalanceView ()
@property (weak, nonatomic) IBOutlet MOLabel *totalIncomeLabel;

@property (weak, nonatomic) IBOutlet MOLabel *yesterdayIncomeLabel;

@property (weak, nonatomic) IBOutlet MOLabel *myDataLabel;
@property (weak, nonatomic) IBOutlet MOLabel *taskLabel;

@end

@implementation MTHomeBalanceView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)commonInit {
    self.userInteractionEnabled = YES;
    // 启用 UILabel 的用户交互
    self.totalIncomeLabel.userInteractionEnabled = YES;
    [self.totalIncomeLabel setEnlargeEdgeWithTop:15 left:15 bottom:15 right:25];
    
    self.yesterdayIncomeLabel.userInteractionEnabled = YES;
    [self.yesterdayIncomeLabel setEnlargeEdgeWithTop:15 left:15 bottom:15 right:25];

    self.myDataLabel.userInteractionEnabled = YES;
    [self.myDataLabel setEnlargeEdgeWithTop:15 left:15 bottom:15 right:25];

    self.taskLabel.userInteractionEnabled = YES;
    [self.taskLabel setEnlargeEdgeWithTop:15 left:15 bottom:15 right:25];

    
    // 创建点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(totalIncomeLabelTapped)];
    // 将手势添加到 UILabel
    [self.totalIncomeLabel addGestureRecognizer:tapGesture];
    
    // 创建点击手势
    UITapGestureRecognizer *tapGesture_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(totalIncomeLabelTapped)];
    // 将手势添加到 UILabel
    [self.yesterdayIncomeLabel addGestureRecognizer:tapGesture_1];
    
    
    
    // 创建点击手势
    UITapGestureRecognizer *dataTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dataLabelTapped)];
    // 将手势添加到 UILabel
    [self.myDataLabel addGestureRecognizer:dataTap];
    
    
    // 创建点击手势
    UITapGestureRecognizer *taskTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taskLabelTapped)];
    // 将手势添加到 UILabel
    [self.taskLabel addGestureRecognizer:taskTap];
}

- (void)reloadUserBalanceWithUser:(MOUserModel *)user {
    self.totalIncomeLabel.text = user.account_balance;
    self.yesterdayIncomeLabel.text = user.yesterday_income;
    self.taskLabel.text = [NSString stringWithFormat:@"%ld", (long)user.task_count];
    self.myDataLabel.text = [NSString stringWithFormat:@"%ld", (long)user.data_count];
}


- (void)totalIncomeLabelTapped {
    DLog(@"totalIncomeLabelTapped");
    if (self.balanceViewClick) {
        self.balanceViewClick();
    }
}

- (void)dataLabelTapped {
    DLog(@"totalIncomeLabelTapped");
    if (self.dataViewClick) {
        self.dataViewClick();
    }
}

- (void)taskLabelTapped {
    DLog(@"totalIncomeLabelTapped");
    if (self.taskViewClick) {
        self.taskViewClick();
    }
}

@end
