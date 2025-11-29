//
//  MOTaskDetailVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import "MOTaskDetailVC.h"
#import "MONavBarView.h"
#import "MOFillTaskTopicTitleView.h"
#import "MOFillTaskTopicSubTitleView.h"
#import "MOTaskDetailModel.h"
#import "MOTaskIntroductionView.h"
#import "MOMyAllDataVC.h"
#import "MOTaskListModel.h"
#import "MORecordingVC.h"
#import "MOPictureFillTaskTopicVC.h"
#import "MOPlainTextFillTaskTopicVC.h"
#import "MOTextFillTaskTopicVC.h"
#import "MOVideoFillTaskTopicVC.h"
#import "MOTaskListModel.h"
#import "MOMyTaskVC.h"
#import "MOMsgAlertView.h"
#import "MOTaskProcessView.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOTaskDetailVC ()
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong)MOButton *fllowBtn;
@property(nonatomic,strong)MOButton *myDataBtn;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)MOView *scrollContentView;
@property(nonatomic,strong)MOFillTaskTopicTitleView *topTitleView;
@property(nonatomic,strong)MOFillTaskTopicSubTitleView *topSubTitleView;
@property(nonatomic,strong)MOTaskIntroductionView *taskIntroductionView;
@property(nonatomic,strong)MOTaskProcessView *taskProcessView;
@property(nonatomic,strong)MOTaskIntroductionView *taskRequirementsView;
@property(nonatomic,strong)MOButton *cancleTaskBtn;
@property(nonatomic,strong)MOView *bottomContentView;
@property(nonatomic,strong)MOButton *bottomBtn;

@property(nonatomic,strong)MOTaskDetailNewModel *taskModel;
@property(nonatomic,assign)NSInteger taskId;
@property(nonatomic,assign)NSInteger userTaskId;
@end

@implementation MOTaskDetailVC

- (instancetype)initWithTaskId:(NSInteger)taskId userTaskId:(NSInteger)userTaskId
{
	self = [super init];
	if (self) {
		self.taskId = taskId;
		self.userTaskId = userTaskId;
	}
	return self;
}


-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.taskModel) {
		[self loadRequestWithSilentMode];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completedOneTopic:) name:CompletedOneTopic object:nil];
	
	[self.fllowBtn addTarget:self action:@selector(fllowBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[self.myDataBtn addTarget:self action:@selector(myDataBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[self.fllowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@(26));
	}];
	[self.fllowBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	[self.myDataBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.width.equalTo(@(isCurrentLanguageChinese?70:90));
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
}

-(void)loadRequestWithSilentMode {
	
	[[MONetDataServer sharedMONetDataServer] getTaskDetailWithTaskId:self.taskId user_task_id:self.userTaskId success:^(NSDictionary *dic) {
		MOTaskDetailNewModel *model = [MOTaskDetailNewModel yy_modelWithJSON:dic];
		self.taskModel = model;
		[self configUI];
		
	} failure:^(NSError *error) {
	} msg:^(NSString *string) {
	} loginFail:^{
	}];
}

-(void)loadRequest {
	
	[self showActivityIndicator];
	[[MONetDataServer sharedMONetDataServer] getTaskDetailWithTaskId:self.taskId user_task_id:self.userTaskId success:^(NSDictionary *dic) {
		[self hidenActivityIndicator];
		MOTaskDetailNewModel *model = [MOTaskDetailNewModel yy_modelWithJSON:dic];
		self.taskModel = model;
		[self layoutUI];
		[self configUI];
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

-(void)layoutUI{
	[self.view addSubview:self.scrollView];
	[self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 20, 0)];
	
	[self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view);
		make.right.equalTo(self.view);
		make.top.equalTo(self.navBar.mas_bottom);
	}];
	
	
	[self.scrollView addSubview:self.scrollContentView];
	[self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.scrollView.mas_left);
		make.right.equalTo(self.scrollView.mas_right);
		make.top.equalTo(self.scrollView.mas_top);
		make.width.equalTo(@(SCREEN_WIDTH));
		make.bottom.equalTo(self.scrollView.mas_bottom);
		
	}];
	
	[self.scrollContentView addSubview:self.topTitleView];
	[self.topTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.scrollContentView.mas_left);
		make.right.equalTo(self.scrollContentView.mas_right);
		make.top.equalTo(self.scrollContentView.mas_top);
		
	}];
	
	
	[self.scrollContentView addSubview:self.topSubTitleView];
	[self.topSubTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.scrollContentView.mas_left);
		make.right.equalTo(self.scrollContentView.mas_right);
		make.top.equalTo(self.topTitleView.mas_bottom);
		make.height.equalTo(@(22));
		
	}];
	
	[self.scrollContentView addSubview:self.taskProcessView];
	[self.taskProcessView configViewWithModel:self.taskModel];
	[self.taskProcessView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.scrollContentView.mas_left);
		make.right.equalTo(self.scrollContentView.mas_right);
		make.top.equalTo(self.topSubTitleView.mas_bottom);
		
	}];
	
	[self.scrollContentView addSubview:self.taskIntroductionView];
	[self.taskIntroductionView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.scrollContentView.mas_left).offset(11);
		make.right.equalTo(self.scrollContentView.mas_right).offset(-11);
		make.top.equalTo(self.taskProcessView.mas_bottom).offset(13);
		
	}];
	
	
	[self.scrollContentView addSubview:self.taskRequirementsView];
	[self.taskRequirementsView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.scrollContentView.mas_left).offset(11);
		make.right.equalTo(self.scrollContentView.mas_right).offset(-11);
		make.top.equalTo(self.taskIntroductionView.mas_bottom).offset(10);
		
	}];
	
	
	[self.scrollContentView addSubview:self.cancleTaskBtn];
	[self.cancleTaskBtn addTarget:self action:@selector(cancleTaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[self.cancleTaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(self.scrollContentView.mas_right).offset(-21);
		make.top.equalTo(self.taskRequirementsView.mas_bottom).offset(10);
		make.bottom.equalTo(self.scrollContentView.mas_bottom);
		
	}];
	
	
	[self.view addSubview:self.bottomContentView];
	[self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
		
		make.left.equalTo(self.view.mas_left);
		make.right.equalTo(self.view.mas_right);
		make.top.equalTo(self.scrollView.mas_bottom);
		make.bottom.equalTo(self.view.mas_bottom);
	}];
	
	[self.bottomContentView addSubview:self.bottomBtn];
	
	[self.bottomBtn addTarget:self action:@selector(bottomBtnClick) forControlEvents:UIControlEventTouchUpInside];
	[self.bottomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
		
		make.left.equalTo(self.bottomContentView.mas_left).offset(16);
		make.right.equalTo(self.bottomContentView.mas_right).offset(-16);
		make.top.equalTo(self.bottomContentView.mas_top).offset(16);
		make.bottom.equalTo(self.bottomContentView.mas_bottom).offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-18);
		make.height.equalTo(@(55));
	}];
	
	
}

-(void)configUI {
	
	NSString *newTitile = self.taskModel.is_follow == 1?NSLocalizedString(@"取消关注",nil):NSLocalizedString(@"+关注",nil);
	[self.fllowBtn setTitles:newTitile];
	
	
	NSInteger completeCount = self.taskModel.topic_type == 1?self.taskModel.try_finished:self.taskModel.finished;
	[self.topTitleView configNoTidViewWithModel:self.taskModel withIndex:completeCount];
	
	NSString *task_details_param = [NSString stringWithFormat:@"%@  PoID:%@",self.taskModel.task_details_param?:@"",self.taskModel.task_no];
	self.topSubTitleView.titleLabel.text = task_details_param;
	NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:self.taskModel.price?:@"" attributes:@{NSForegroundColorAttributeName:Color9A1E2E,NSFontAttributeName:MOPingFangSCBoldFont(20)}];
	NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.taskModel.currency_unit] attributes:@{NSForegroundColorAttributeName:Color9A1E2E,NSFontAttributeName:MOPingFangSCBoldFont(12)}];
	[str2 appendAttributedString:str1];
	
	self.topSubTitleView.priceLabel.attributedText = str2;
	
	self.taskProcessView.titleLabel.text = NSLocalizedString(@"项目流程", nil);
	[self.taskProcessView configViewWithModel:self.taskModel];
	
	self.taskIntroductionView.titleLabel.text = NSLocalizedString(@"项目介绍", nil);
	self.taskIntroductionView.exampleBtn.hidden = YES;
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	// 设置行间距为 10 点
	paragraphStyle.lineSpacing = 18;
	paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
	NSMutableAttributedString *introductionText = [[NSMutableAttributedString alloc] initWithString:self.taskModel.data_detail?:@"" attributes:@{NSForegroundColorAttributeName:BlackColor,NSFontAttributeName:MOPingFangSCMediumFont(14),NSParagraphStyleAttributeName:paragraphStyle}];
	self.taskIntroductionView.textLabel.attributedText = introductionText;
	
	
	
	self.taskRequirementsView.titleLabel.text = NSLocalizedString(@"项目要求",nil);
	self.taskRequirementsView.exampleBtn.hidden = [self.taskModel.example_url length] == 0;
	NSMutableAttributedString *requirementText = [[NSMutableAttributedString alloc] initWithString:self.taskModel.recording_requirements?:@"" attributes:@{NSForegroundColorAttributeName:BlackColor,NSFontAttributeName:MOPingFangSCMediumFont(14),NSParagraphStyleAttributeName:paragraphStyle}];
	
	self.taskRequirementsView.textLabel.attributedText = requirementText;
	self.taskRequirementsView.exampleBtn.hidden = [self.taskModel.example_url length] == 0;
	WEAKSELF
	self.taskRequirementsView.didExampleBtnClick = ^{
		
		[MOWebViewController pushWebVCWithUrl:weakSelf.taskModel.example_url?:@"" title:NSLocalizedString(@"样例", nil)];
	};
	
	if (self.taskModel.task_status.integerValue == 0 || self.taskModel.task_status.integerValue >= 4) {
		self.cancleTaskBtn.hidden = YES;
	} else {
		self.cancleTaskBtn.hidden = NO;
	}
	
	
	[self.bottomContentView addSubview:self.bottomBtn];
	
	
	
	[self setBottomTitleWithTask_status:[self.taskModel.task_status integerValue]];
	
	
	
}

-(void)setBottomTitleWithTask_status:(NSInteger)task_status {
	
	NSDictionary *btnTitlesDict = @{@(0):NSLocalizedString(@"领取项目",nil),@(1):NSLocalizedString(@"参与项目",nil),@(2):NSLocalizedString(@"等待审核",nil),@(3):NSLocalizedString(@"修正项目",nil),@(4):NSLocalizedString(@"查看项目",nil),@(5):NSLocalizedString(@"查看项目",nil)};
	
	NSDictionary *btnTestTitlesDict = @{@(0):NSLocalizedString(@"开始测试",nil),@(1):NSLocalizedString(@"参与项目",nil),@(2):NSLocalizedString(@"等待审核",nil),@(3):NSLocalizedString(@"修正项目",nil),@(4):NSLocalizedString(@"查看项目",nil),@(5):NSLocalizedString(@"查看项目",nil)};
	NSString *btnTitlele = btnTitlesDict[@(task_status)];
	if (self.taskModel.is_try) {
		btnTitlele = btnTestTitlesDict[@(task_status)];
	}
	
	[self.bottomBtn setTitles:btnTitlele];
}


-(void)requestReceiveATask{
	
	[self showActivityIndicator];
	MOTaskListModel *model = self.taskModel;
	if (self.taskModel.task_type == 2) {
		
		[[MONetDataServer sharedMONetDataServer] receiveATaskV2WithTaskid:model.task_id lat:[MOLocationManager shared].latitude lng:[MOLocationManager shared].longitude success:^(NSInteger index) {
			[self hidenActivityIndicator];
			model.user_task_id = index;
			model.is_get = YES;
			model.task_status = @(1);
			[self configUI];
			[self setBottomTitleWithTask_status:1];
			if (self.taskModel.task_type == 2) {
				[self goProcessTaskWithModel:model];
				return;
			}
			[self goFillTaskVCWithModel:model];
			if (self.didChangedRecevingTaskStatuts) {
				self.didChangedRecevingTaskStatuts(NO);
			}
		} failure:^(NSError *error) {
			[self hidenActivityIndicator];
			[self showErrorMessage:error.localizedDescription];
		} msg:^(NSString *string) {
			[self hidenActivityIndicator];
			[self showErrorMessage:string];
		} loginFail:^{
			[self hidenActivityIndicator];
		}];
		return;
	}
	[[MONetDataServer sharedMONetDataServer] receiveATaskWithTaskid:model.task_id lat:[MOLocationManager shared].latitude lng:[MOLocationManager shared].longitude success:^(NSInteger index) {
		[self hidenActivityIndicator];
		model.user_task_id = index;
		model.is_get = YES;
		model.task_status = @(1);
		[self configUI];
		[self setBottomTitleWithTask_status:1];
		if (self.taskModel.task_type == 2) {
			[self goProcessTaskWithModel:model];
			return;
		}
		[self goFillTaskVCWithModel:model];
		if (self.didChangedRecevingTaskStatuts) {
			self.didChangedRecevingTaskStatuts(NO);
		}
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

-(void)bottomBtnClick {
    MOTaskListModel *model = self.taskModel;
    
    if (model.is_get && model.user_task_id == 0) {
		
		if ([MOLocationManager shared].latitude == 0) {
			WEAKSELF
			[self showActivityIndicator];
			[MOLocationManager shared].onLocationUpdate = ^(double latitude, double longitude,BOOL success) {
				[weakSelf requestReceiveATask];
			};
			[[MOLocationManager shared] startUpdatingLocation];
			return;
		}
		
		[self requestReceiveATask];
		
        
    } else {
		
		if (self.taskModel.task_type == 2) {
			[self goProcessTaskWithModel:model];
			return;
		}
		
        [self goFillTaskVCWithModel:model];
    }
    
    
}


-(void)goProcessTaskWithModel:(MOTaskListModel *)model {
	
	if (model.cate == 1) {
		MOProcessTaskListVC * vc = [[MOProcessTaskListVC alloc] initWithTaskDetail:self.taskModel];
		[MOAppDelegate.transition pushViewController:vc animated:YES];
	}
}


-(void)goFillTaskVCWithModel:(MOTaskListModel *)model {
    
    MOBaseFillTaskTopicTemplateVC *vc;
    if (model.cate == 1) {
        
        // 录音项目
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        vc = (MORecordingVC *)[storyBoard instantiateViewControllerWithIdentifier:@"MORecordingVC"];
        MORecordingVC *tagetVC = vc;
        tagetVC.taskListModel = model;
        tagetVC.task_status = [model.task_status integerValue];
		
		
		
    }
    
    if (model.cate == 2) {
        vc =  [[MOPictureFillTaskTopicVC alloc] initWithTaskModel:model];
    }
    
    
    if (model.cate == 3) {
        
        if (model.is_plain_text) {
            vc = [[MOPlainTextFillTaskTopicVC alloc] initWithTaskModel:model];
        } else {
            vc =  [[MOTextFillTaskTopicVC alloc] initWithTaskModel:model];
        }
    }
    
    
    
    if (model.cate == 4) {
        vc =  [[MOVideoFillTaskTopicVC alloc] initWithTaskModel:model];
    }
    
    WEAKSELF
    vc.taskStatusChangeed = ^(NSInteger taskStatus) {
        weakSelf.taskModel.task_status = @(taskStatus);
        [weakSelf setBottomTitleWithTask_status:taskStatus];
    };
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}





-(void)fllowBtnClick {
    if (self.taskModel.is_follow) {
        WEAKSELF
        [MOMsgAlertView showWithTitle:NSLocalizedString(@"温馨提示", nil) andMsg:NSLocalizedString(@"确定要取消关注吗?", nil) andSureClickHandle:^{
            [weakSelf requestFollowTask];
        }];
    } else {
        [self requestFollowTask];
    }
}

-(void)requestFollowTask {
    
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


-(void)myDataBtnClick {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOMyTaskVC"];
    [MOAppDelegate.transition pushViewController:targetVC animated:YES];
}

-(void)cancleTaskBtnClick{
	
	
	WEAKSELF
	[MOMsgAlertView showWithTitle:NSLocalizedString(@"温馨提示", nil) andMsg:NSLocalizedString(@"确定要放弃项目吗?", nil) andSureClickHandle:^{
		[weakSelf showActivityIndicator];
		[[MONetDataServer sharedMONetDataServer] recycleTaskWithUserTaskId:self.taskModel.user_task_id success:^(NSInteger index) {
			[weakSelf hidenActivityIndicator];
			weakSelf.taskModel.task_status = @(0);
			weakSelf.taskModel.user_task_id = 0;
			weakSelf.taskModel.is_get = 1;
			[weakSelf configUI];
			[weakSelf setBottomTitleWithTask_status:0];
			if (weakSelf.didChangedRecevingTaskStatuts) {
				weakSelf.didChangedRecevingTaskStatuts(YES);
			}
		} failure:^(NSError *error) {
			[weakSelf hidenActivityIndicator];
			[weakSelf showErrorMessage:error.localizedDescription];
		} msg:^(NSString *string) {
			[weakSelf hidenActivityIndicator];
			[weakSelf showErrorMessage:string];
		} loginFail:^{
			[weakSelf hidenActivityIndicator];
		}];

		
	}];
	
}

-(void)completedOneTopic:(NSNotification *)noti {
    
    
    if (!([self.taskModel.task_status integerValue] == 0 || [self.taskModel.task_status integerValue] == 1)) {
        
        return;
    }
    NSDictionary *userInfo =  noti.userInfo;
    NSNumber *currentQuestionIndex = userInfo[@"currentQuestionIndex"];
    
    NSInteger completeCount = 0;
    if (self.taskModel.topic_type == 1) {
        self.taskModel.try_finished = [currentQuestionIndex integerValue] +1;
        completeCount = self.taskModel.try_finished;
    } else {
        self.taskModel.finished = [currentQuestionIndex integerValue] +1;
        completeCount = self.taskModel.finished;
    }
    [self.topTitleView configNoTidViewWithModel:self.taskModel withIndex:completeCount];
}


#pragma mark - setter && getter
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
        [_myDataBtn setTitle:NSLocalizedString(@"我的项目",nil) titleColor:Color9A1E2E bgColor:[Color9A1E2E colorWithAlphaComponent:0.1] font:MOPingFangSCBoldFont(12)];
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


-(MOFillTaskTopicSubTitleView *)topSubTitleView {
    
    if (!_topSubTitleView) {
        _topSubTitleView = [MOFillTaskTopicSubTitleView new];
        _topSubTitleView.backgroundColor = WhiteColor;
    }
    return _topSubTitleView;
}

-(MOTaskProcessView *)taskProcessView {
    
    if (!_taskProcessView) {
        _taskProcessView = [MOTaskProcessView new];
        _taskProcessView.backgroundColor = WhiteColor;
        [_taskProcessView cornerRadius:QYCornerRadiusBottom radius:20];
        
    }
    return _taskProcessView;
}

-(MOTaskIntroductionView *)taskIntroductionView {
    
    if (!_taskIntroductionView) {
        _taskIntroductionView = [MOTaskIntroductionView new];
        _taskIntroductionView.backgroundColor = WhiteColor;
        [_taskIntroductionView cornerRadius:QYCornerRadiusAll radius:20];
        
    }
    return _taskIntroductionView;
}

-(MOTaskIntroductionView *)taskRequirementsView {
    
    if (!_taskRequirementsView) {
        _taskRequirementsView = [MOTaskIntroductionView new];
        _taskRequirementsView.backgroundColor = WhiteColor;
        [_taskRequirementsView cornerRadius:QYCornerRadiusAll radius:20];
    }
    return _taskRequirementsView;
}

-(MOButton *)cancleTaskBtn {
	
	if (!_cancleTaskBtn) {
		_cancleTaskBtn = [MOButton new];
		[_cancleTaskBtn setTitle:NSLocalizedString(@"放弃项目", nil) titleColor:ColorAFAFAF bgColor:ClearColor font:MOPingFangSCBoldFont(12)];
		[_cancleTaskBtn setImage:[UIImage imageNamedNoCache:@"icon_abort_mission"]];
		[_cancleTaskBtn setEnlargeEdgeWithTop:5 left:5 bottom:5 right:5];
		_cancleTaskBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 4);
		_cancleTaskBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
	}
	return  _cancleTaskBtn;
}


-(MOView *)bottomContentView {
    
    if (!_bottomContentView) {
        _bottomContentView = [MOView new];
        _bottomContentView.backgroundColor = WhiteColor;
    }
    
    return _bottomContentView;
}



-(MOButton *)bottomBtn {
    
    if (!_bottomBtn) {
        _bottomBtn = [MOButton new];
        [_bottomBtn setTitle:NSLocalizedString(@"参与项目", nil) titleColor:WhiteColor bgColor:Color9A1E2E font:MOPingFangSCHeavyFont(16)];
        [_bottomBtn cornerRadius:QYCornerRadiusAll radius:14];
        
    }
    
    return _bottomBtn;
}

@end
