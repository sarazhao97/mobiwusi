//
//  MOBaseScheduleCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOTableViewCell.h"
#import "MOUserTaskDataModel.h"
NS_ASSUME_NONNULL_BEGIN
@class MOBaseDataContentView;
@interface MOBaseScheduleCell : MOTableViewCell
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)MOBaseDataContentView *dataContentView;
@property(nonatomic,strong)MOView *scheduleCircleView;
@property(nonatomic,strong)MOView *scheduleVerticalTopView;
@property(nonatomic,strong)MOView *scheduleVerticalBottomView;
@property(nonatomic,copy)void(^didMsgBtnClick)(void);
@property(nonatomic,copy)void(^didEditBtnClick)(void);

+(NSMutableAttributedString *)createTryTagAttributedStringWithTitle:(NSString *)dataTitle;
+(NSMutableAttributedString *)createNoTryTagAttributedStringWithTitle:(NSString *)dataTitle;
-(void)configCellData:(MOUserTaskDataModel *)data;
@end

@interface MOBaseDataContentView : MOView
@property(nonatomic,strong)MOView *categoryDataView;
@property(nonatomic,strong)UILabel *didTageLabel;
@property(nonatomic,strong)MOButton *msgBtn;
@property(nonatomic,strong)MOView *redDotView;
@property(nonatomic,strong)MOButton *editBtn;
@property(nonatomic,strong)MOButton *locationBtn;
@end

NS_ASSUME_NONNULL_END
