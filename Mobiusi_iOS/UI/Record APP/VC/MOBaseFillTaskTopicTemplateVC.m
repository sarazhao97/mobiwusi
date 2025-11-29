//
//  MOBaseFillTaskTopicTemplateVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOBaseFillTaskTopicTemplateVC.h"
#import "MOTopErrorTipView.h"
#import "MOMsgAlertView.h"


@interface MOBaseFillTaskTopicTemplateVC ()

@property(nonatomic,strong)MOTopErrorTipView *topErrorView;
@end

@implementation MOBaseFillTaskTopicTemplateVC
@synthesize navBar = _navBar;
@synthesize fllowBtn = _fllowBtn;
@synthesize myDataBtn = _myDataBtn;
@synthesize scrollView = _scrollView;
@synthesize scrollContentView = _scrollContentView;
@synthesize topTitleView = _topTitleView;
@synthesize step1View = _step1View;
@synthesize bottomContentView = _bottomContentView;
@synthesize bottomLabel = _bottomLabel;
@synthesize bottomBtn = _bottomBtn;
@synthesize alertView = _alertView;
@synthesize prevNextButtonSetView = _prevNextButtonSetView;
@synthesize questionListStateView = _questionListStateView;



- (instancetype)initWithTaskModel:(MOTaskListModel *)taskModel;
{
    self = [super init];
    if (self) {
        self.taskModel = taskModel;
    }
    return self;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.fllowBtn addTarget:self action:@selector(fllowBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.myDataBtn addTarget:self action:@selector(myDataBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.fllowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(26));
    }];
    //    [self.fllowBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.fllowBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.myDataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(70));
        make.height.equalTo(@(26));
    }];
    [self.navBar.backBtn setImage:[UIImage imageNamedNoCache:@"icon_nav_back_b.png"]];
    [self.navBar.rightItemsView addArrangedSubview:self.fllowBtn];
    [self.navBar.rightItemsView addArrangedSubview:self.myDataBtn];
    [self.view addSubview:self.navBar];
    self.navBar.gobackDidClick = ^{
        
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
    }];
    
    [self loadRequest];
    
    WEAKSELF
    if (self.taskModel.is_follow == 1) {
        [self.fllowBtn setTitles:NSLocalizedString(@"取消关注",nil)];
    }
    self.didFllowBtnClick = ^{
        
        if (weakSelf.taskModel.is_follow) {
            [MOMsgAlertView showWithTitle:NSLocalizedString(@"温馨提示", nil) andMsg:NSLocalizedString(@"确定要取消关注吗?", nil) andSureClickHandle:^{
                [weakSelf fllowTaskRequest];
            }];
        } else {
            [weakSelf fllowTaskRequest];
        }
        
    };
    
}

-(void)loadRequest {
    
    [self getUserTaskTopicList];
}

-(void)fllowTaskRequest {
    
    
    NSInteger action = self.taskModel.is_follow == 1?2:1;
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] followTaskWithTaskId:self.taskModel.task_id action:action success:^(NSInteger index) {
        [self hidenActivityIndicator];
        [self showMessage:NSLocalizedString(@"操作成功",nil)];
        self.taskModel.is_follow = self.taskModel.is_follow == 1?0:1;
        NSString *newTitile = self.taskModel.is_follow == 1?NSLocalizedString(@"取消关注",nil):NSLocalizedString(@"+关注",nil);
        [self.fllowBtn setTitles:newTitile];
        
    } failure:^(NSError *error) {
        [self hidenActivityIndicator];
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self hidenActivityIndicator];
        [self showErrorMessage:string];
    } loginFail:^{
        [self hidenActivityIndicator];
    }];
}

-(BOOL)canEdit {
    
    //后台说，能不能改是根据任务的的状态判断，不是每个问题的状态
    return [self.taskModel.task_status integerValue] == 0 || [self.taskModel.task_status integerValue] == 3 || [self.taskModel.task_status integerValue] == 1;
    
}

-(BOOL)canSubmitData {
    
    MOTaskQuestionModel *questionMode = nil;
    if (self.questionDetail.data.count-1 >= self.currentQuestionIndex) {
        questionMode = self.questionDetail.data[self.currentQuestionIndex];
    }
    BOOL questionStatus = questionMode.status == 0 || questionMode.status == 3;
    return [self canEdit] && questionStatus;
}


-(void)getUserTaskTopicList {
    
    MOTaskListModel *model = self.taskModel;
    
    [self showActivityIndicator];
    
    [[MONetDataServer sharedMONetDataServer] getUserTaskTopicWithTaskId:model.task_id user_task_id:model.user_task_id task_status:[model.task_status integerValue] topic_type:model.topic_type success:^(NSDictionary *dic) {
        [self hidenActivityIndicator];
        
        MORecordTaskDetailModel *questionDetail = [MORecordTaskDetailModel yy_modelWithJSON:dic];
        NSMutableArray<MOTaskQuestionModel *> *data = [NSMutableArray new];
        for (NSDictionary *questionDict in dic[@"data"]) {
            MOTaskQuestionModel *question = [MOTaskQuestionModel yy_modelWithJSON:questionDict];
            [data addObject:question];
        }
        questionDetail.data = [data copy];
        self.questionDetail = questionDetail;
        if (questionDetail.complete < questionDetail.count) {
            self.currentQuestionIndex = questionDetail.complete;
        } else {
            self.currentQuestionIndex = 0;
        }
        if (self.questionDetail.data.count == 0) {
            
            [self showMessage:@"当前题目数据为空！"];
            [MOAppDelegate.transition popViewControllerAnimated:YES];
            
            return;
        }
		self.selectQuestionLimitIndex = self.currentQuestionIndex;
		if (questionDetail.complete == questionDetail.count) {
			self.selectQuestionLimitIndex = questionDetail.count;
		}
        [self configUIAfterReceivingData];

    } failure:^(NSError *error) {
        [self hidenActivityIndicator];
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self hidenActivityIndicator];
        [self showErrorMessage:string];
    } loginFail:^{
        [self hidenActivityIndicator];
    }];
}


-(void)configUIAfterReceivingData {
    
    
    
    MOTaskQuestionModel *questionMode = nil;
    if (self.questionDetail.data.count-1 >= self.currentQuestionIndex) {
        questionMode = self.questionDetail.data[self.currentQuestionIndex];
    }
    self.topTitleView.tidLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PoID:%@", nil),self.taskModel.task_no];
    WEAKSELF
    [self.view addSubview:self.scrollView];
    [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 20, 0)];
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    
    [self.scrollView addSubview:self.scrollContentView];
    [self.scrollContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView.mas_left);
        make.right.equalTo(self.scrollView.mas_right);
        make.top.equalTo(self.scrollView.mas_top);
        make.width.equalTo(@(SCREEN_WIDTH));
        make.bottom.equalTo(self.scrollView.mas_bottom);
        
    }];
    
    
    if ([self.taskModel.task_status integerValue] == 3 && questionMode.status == 3) {
        [self.scrollContentView addSubview:self.topErrorView];
        self.topErrorView.errorLabel.text = [NSString stringWithFormat:NSLocalizedString(@"未通过原因：%@", nil),questionMode.remark?:@""];
        [self.topErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.scrollContentView.mas_top);
            
        }];
        
        [self.scrollContentView addSubview:self.topTitleView];
        [self.topTitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.topErrorView.mas_bottom);
            
        }];
    } else {
        
        [self.scrollContentView addSubview:self.topTitleView];
        [self.topTitleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.scrollContentView.mas_top);
            
        }];
    }
    
    [self.scrollContentView addSubview:self.questionListStateView];
    [self.questionListStateView configViewWithQuestionList1:self.questionDetail.data selectedIndex:self.currentQuestionIndex taskModel1:self.taskModel];
	self.questionListStateView.didClickNewIndex = ^(NSInteger index) {
		if (index > weakSelf.selectQuestionLimitIndex) {
			return;
		}
		weakSelf.currentQuestionIndex = index;
		[weakSelf resetUI];
	};
    [self.questionListStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollContentView.mas_left);
        make.right.equalTo(self.scrollContentView.mas_right);
        make.top.equalTo(self.topTitleView.mas_bottom);
    }];
    
    
    [self.scrollContentView addSubview:self.step1View];
    [self.step1View mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollContentView.mas_left);
        make.right.equalTo(self.scrollContentView.mas_right);
        make.top.equalTo(self.questionListStateView.mas_bottom);
    }];
    
    
    [self.view addSubview:self.bottomContentView];
    if ([self canEdit]) {
        [self hiddenBottomView];
    } else {
        [self showBottomView];
    }
    
    
    [self.bottomContentView addSubview:self.bottomLabel];
    [self.bottomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.bottomContentView.mas_left).offset(16);
        make.right.equalTo(self.bottomContentView.mas_right).offset(-16);
        make.top.equalTo(self.bottomContentView.mas_top).offset(10);
    }];
    
    
    [self.bottomContentView addSubview:self.bottomBtn];
    [self.bottomBtn addTarget:self action:@selector(bottomBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.bottomContentView.mas_left).offset(16);
        make.right.equalTo(self.bottomContentView.mas_right).offset(-16);
        make.top.equalTo(self.bottomLabel.mas_bottom).offset(15);
        make.bottom.equalTo(self.bottomContentView.mas_bottom).offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-18);
        make.height.equalTo(@(55));
    }];
    
    [self.bottomContentView addSubview:self.prevNextButtonSetView];
    self.prevNextButtonSetView.didPrevBtnClick = ^{
        if ( weakSelf.currentQuestionIndex == 0) {
            return;
        }
        weakSelf.currentQuestionIndex -= 1;
        [weakSelf resetUI];
    };
    self.prevNextButtonSetView.didNextBtnClick = ^{
        
        if ( weakSelf.currentQuestionIndex + 1 ==  self.questionDetail.count) {
            return;
        }
        weakSelf.currentQuestionIndex += 1;
        [weakSelf resetUI];
    };
    self.prevNextButtonSetView.didsaveBtnClick = ^{
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    };
    
    [self.prevNextButtonSetView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.bottomContentView.mas_left).offset(16);
        make.right.equalTo(self.bottomContentView.mas_right).offset(-16);
        make.top.equalTo(self.bottomLabel.mas_bottom).offset(15);
        make.bottom.equalTo(self.bottomContentView.mas_bottom).offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-18);
    }];
    
    [self.bottomBtn cornerRadius:QYCornerRadiusAll radius:14];
    
    
    [self.view addSubview:self.alertView];
    [self.alertView setTaskRequirement:self.taskModel.recording_requirements];
    [self.alertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.topTitleView configViewWithModel:self.taskModel withIndex:self.currentQuestionIndex + 1 total:self.questionDetail.count];
    
    
    [self.step1View setRequreStringToAttributedString:questionMode.demand?:self.taskModel.recording_requirements];
    
    self.step1View.didViewRequireBtnClick = ^{
        weakSelf.alertView.hidden = NO;
    };
    
    self.bottomLabel.text = NSLocalizedString(@"Step3：确认数据", nil);
    
    [self changeBottomViewStyle];
    
    
}

-(void)changeBottomViewStyle {
    
    //可以填数据的时候，底部按钮始终只有一个
    if ([self canSubmitData]) {
        self.bottomBtn.hidden = NO;
        self.prevNextButtonSetView.hidden = YES;
        if (self.currentQuestionIndex + 1 < self.questionDetail.count) {
            [self.bottomBtn  setTitle:NSLocalizedString(@"下一条", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCBoldFont(16)];
        } else {
            
            [self.bottomBtn  setTitle:NSLocalizedString(@"保存", nil) titleColor:WhiteColor bgColor:MainSelectColor font:MOPingFangSCBoldFont(16)];
        }
        
    } else {
        
        if (self.currentQuestionIndex == 0) {
            self.bottomBtn.hidden = YES;
            self.prevNextButtonSetView.hidden = NO;
        }
        
        if (self.currentQuestionIndex > 0 && self.currentQuestionIndex + 1 < self.questionDetail.count) {
            self.bottomBtn.hidden = YES;
            self.prevNextButtonSetView.hidden = NO;
        }
        
        if ( self.currentQuestionIndex + 1 == self.questionDetail.count && self.questionDetail.count > 1) {
            self.bottomBtn.hidden = YES;
            self.prevNextButtonSetView.hidden = NO;
        }
        if (self.questionDetail.count == 1) {
            self.bottomBtn.hidden = YES;
            self.prevNextButtonSetView.hidden = NO;
//            self.prevNextButtonSetView.nextBtn.hidden = YES;
//            self.prevNextButtonSetView.prevBtn.hidden = YES;
//            self.prevNextButtonSetView.saveBtn.hidden = NO;
        }

    }
}


-(void)showBottomView {
    
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
    }];
    
    self.bottomContentView.hidden = NO;
    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.scrollView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

-(void)hiddenBottomView {
    
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.navBar.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    self.bottomContentView.hidden = YES;
    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.scrollView.mas_bottom);
    }];
}


-(void)bottomBtnClick {
    
    if (self.didBottomBtnClick) {
        self.didBottomBtnClick();
    } else {
        
        if ([self canSubmitData]) {
            [self submitData];
            return;
        }
        
        if (self.currentQuestionIndex + 1 == self.questionDetail.count) {
            self.currentQuestionIndex -= 1;
        } else {
            self.currentQuestionIndex += 1;
        }
        
        [self resetUI];
    }
}

-(void)fllowBtnClick {
    
    if (self.didFllowBtnClick) {
        self.didFllowBtnClick();
    }
}


-(void)myDataBtnClick {
    
    if (self.didMyDataBtnClick) {
        self.didMyDataBtnClick();
    }
    
}

-(void)resetUI{
    [self configUIAfterReceivingData];
}

-(void)submitData {
    
}

#pragma mark - setter && getter

-(MOTopErrorTipView *)topErrorView {
    
    if (!_topErrorView) {
        _topErrorView = [MOTopErrorTipView new];
    }
    return _topErrorView;
}
-(MONavBarView *)navBar {
    
    if (!_navBar) {
        _navBar = [MONavBarView new];
        _navBar.titleLabel.text = @"";
        _navBar.backgroundColor = WhiteColor;
    }
    
    return _navBar;
}


-(MOButton *)fllowBtn {
    
    if (!_fllowBtn) {
        _fllowBtn = [MOButton new];
        [_fllowBtn setTitle:NSLocalizedString(@"+关注",nil) titleColor:Color002FA7 bgColor:[Color002FA7 colorWithAlphaComponent:0.1] font:MOPingFangSCBoldFont(12)];
        [_fllowBtn cornerRadius:QYCornerRadiusAll radius:10];
        [_myDataBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:0];
    }
    
    return _fllowBtn;
}

-(MOButton *)myDataBtn {
    
    if (!_myDataBtn) {
        _myDataBtn = [MOButton new];
        [_myDataBtn setTitle:NSLocalizedString(@"我的图片", nil) titleColor:Color9A1E2E bgColor:[Color9A1E2E colorWithAlphaComponent:0.1] font:MOPingFangSCBoldFont(12)];
        [_myDataBtn cornerRadius:QYCornerRadiusAll radius:10];
        [_myDataBtn setEnlargeEdgeWithTop:10 left:0 bottom:10 right:10];
    }
    
    return _myDataBtn;
}

-(UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.backgroundColor = ClearColor;
        
    }
    
    return _scrollView;
}


-(MOQuestionListStateView *)questionListStateView {
    
    if (!_questionListStateView) {
        _questionListStateView = [MOQuestionListStateView new];
        _questionListStateView.backgroundColor = WhiteColor;
        [_questionListStateView cornerRadius:QYCornerRadiusBottom radius:20];
    }
    return _questionListStateView;
}

-(MOView *)scrollContentView {
    
    if (!_scrollContentView) {
        _scrollContentView = [MOView new];
        _scrollContentView.backgroundColor = ClearColor;
    }
    
    return _scrollContentView;
}

-(MOFillTaskTopicTitleView *)topTitleView {
    
    if (!_topTitleView) {
        _topTitleView = [MOFillTaskTopicTitleView new];
        _topTitleView.backgroundColor = WhiteColor;
    }
    
    return _topTitleView;
}


- (MOFillTaskTopicStep1View *)step1View {
    
    if (!_step1View) {
        _step1View = [MOFillTaskTopicStep1View new];
    }
    
    return _step1View;
}

-(MOView *)bottomContentView {
    
    if (!_bottomContentView) {
        _bottomContentView = [MOView new];
        _bottomContentView.backgroundColor = WhiteColor;
    }
    
    return _bottomContentView;
}

-(UILabel *)bottomLabel {
    
    if (!_bottomLabel) {
        _bottomLabel = [UILabel labelWithText:@"" textColor:Color626262 font:MOPingFangSCMediumFont(12)];
    }
    return _bottomLabel;
}

-(MOButton *)bottomBtn {
    
    if (!_bottomBtn) {
        _bottomBtn = [MOButton new];
        
    }
    
    return _bottomBtn;
}

-(MOPrevNextButtonSetView *)prevNextButtonSetView {
    
    if (!_prevNextButtonSetView) {
        _prevNextButtonSetView = [MOPrevNextButtonSetView new];
    }
    return _prevNextButtonSetView;
}


- (MORecordTaskAlertView *)alertView {
    if (_alertView == nil) {
        _alertView = [[[NSBundle mainBundle]loadNibNamed:@"MORecordTaskAlertView" owner:nil options:nil] lastObject];
    }
    return _alertView;
}

@end
