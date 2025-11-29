//
//  MOBaseFillTaskTopicTemplateVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOBaseViewController.h"
#import "MONavBarView.h"
#import "MOFillTaskTopicStep1View.h"
#import "MOFillTaskTopicTitleView.h"
#import "MORecordTaskAlertView.h"
#import "MOTaskListModel.h"
#import "MORecordTaskDetailModel.h"
#import "MOWebViewController.h"
#import "MOPrevNextButtonSetView.h"
#import "Mobiusi_iOS-Swift.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOBaseFillTaskTopicTemplateVC : MOBaseViewController
@property(nonatomic,strong)MOTaskListModel *taskModel;
@property (nonatomic, strong)MORecordTaskDetailModel *questionDetail;
@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger selectQuestionLimitIndex;
@property(nonatomic,strong,readonly)MONavBarView *navBar;
@property(nonatomic,strong,readonly)MOButton *fllowBtn;
@property(nonatomic,strong,readonly)MOButton *myDataBtn;

@property(nonatomic,strong,readonly)UIScrollView *scrollView;
@property(nonatomic,strong,readonly)MOView *scrollContentView;
@property(nonatomic,strong,readonly)MOFillTaskTopicTitleView *topTitleView;
@property(nonatomic,strong,readonly)MOQuestionListStateView *questionListStateView;

@property(nonatomic,strong,readonly)MOFillTaskTopicStep1View *step1View;


@property(nonatomic,strong,readonly)MOView *bottomContentView;
@property(nonatomic,strong,readonly)UILabel *bottomLabel;
@property(nonatomic,strong,readonly)MOButton *bottomBtn;
@property(nonatomic,strong,readonly)MOPrevNextButtonSetView *prevNextButtonSetView;

@property (nonatomic, strong,readonly) MORecordTaskAlertView *alertView;

@property(nonatomic,copy)void(^didFllowBtnClick)(void);
@property(nonatomic,copy)void(^didMyDataBtnClick)(void);
@property(nonatomic,copy)void(^didBottomBtnClick)(void);

@property(nonatomic,copy)void(^taskStatusChangeed)(NSInteger taskStatus);

- (instancetype)initWithTaskModel:(MOTaskListModel *)taskModel;
-(void)configUIAfterReceivingData;
-(BOOL)canEdit;
-(BOOL)canSubmitData;
-(void)showBottomView;
-(void)hiddenBottomView;
-(void)resetUI;
//子类实现自己的提交数据
-(void)submitData;
@end

NS_ASSUME_NONNULL_END
