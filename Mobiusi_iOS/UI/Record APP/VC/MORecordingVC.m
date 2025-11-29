//
//  MORecordingVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/15.
//

#import "MORecordingVC.h"
#import "MORecordTaskAlertView.h"
#import "MOMicAnimationView.h"
#import "MOTaskDetailModel.h"
#import "MORecordTaskDetailModel.h"
#import <AVFoundation/AVFoundation.h>
#import "MOVoicePlayView.h"
#import "MOMyAudioDataVC.h"
#import "MOMsgAlertView.h"
#import <UITextView+ZWPlaceHolder.h>
#import "Mobiusi_iOS-Swift.h"

@interface MORecordingVC ()<AVAudioPlayerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet MOButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *step1Label;
@property (weak, nonatomic) IBOutlet UITextView *taskRequireTv;
@property (weak, nonatomic) IBOutlet UILabel *step2Label;
@property (weak, nonatomic) IBOutlet UIView *readTextView;
@property (weak, nonatomic) IBOutlet UILabel *readTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *step4Label;
@property (weak, nonatomic) IBOutlet UIView *listenView;
@property (weak, nonatomic) IBOutlet UILabel *step3Label;
@property (weak, nonatomic) IBOutlet UIButton *samplePlayButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) MOMicAnimationView *micInputAnimationView;
@property (weak, nonatomic) IBOutlet UILabel *step5Label;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *againButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *reasonView;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reasonViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;
@property (weak, nonatomic) IBOutlet UILabel *inputTextLabel;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@property (weak, nonatomic) IBOutlet MOQuestionListStateView *questionListStateView;


/// 任务要求
@property (nonatomic, strong) MORecordTaskAlertView *alertView;
/// 当前展示的题目
@property (nonatomic, strong) MORecordTaskDetailModel *questionDetail;
@property (nonatomic, strong) MOTaskQuestionModel *currentQuestion;
@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, assign) NSInteger selectQuestionLimitIndex;

@property (nonatomic, strong) AVAudioRecorder *recorder;//音频录音机
@property (nonatomic, strong) NSTimer *levelTimer; // 监听录音分贝大小的定时器
@property (nonatomic, copy) NSString *recordFileName;// 录音文件名

@property (nonatomic, strong) UILabel *countdownLabel;   // 用于显示倒计时的标签
@property (nonatomic, strong) NSTimer *timer;             // 录音前倒计时的定时器
@property (nonatomic, assign) NSInteger countdownValue;   // 当前倒计时的值

/// 音频播放器相关
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;// 本地音频播放器
@property (nonatomic, strong) AVPlayer *avPlayer; // 网络音频播放
@property (nonatomic, strong) NSTimer *progressTimer; // 播放进度
@property (nonatomic, assign) NSTimeInterval audioDuration;
@property (nonatomic, assign) BOOL isLocalAudio;
@property (nonatomic, strong) NSString *urlString; // 保存配置的URL
@property (nonatomic, strong) MOVoicePlayView *voicePlayView;
@property(nonatomic,strong)UIVisualEffectView *blurEffectView;
@end

@implementation MORecordingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    self.recordFileName = @"";
    self.readTextView.layer.cornerRadius = 20.f;
    self.readTextView.layer.borderWidth = 2.f;
    self.readTextView.layer.borderColor = MainSelectColor.CGColor;
    self.reasonView.hidden = YES;
    self.reasonViewHeight.constant = 0;
    self.titleTop.constant = 8;
    
    [self.listenView addSubview:self.voicePlayView];
    [self.voicePlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.listenView).mas_offset(15);
        make.bottom.equalTo(self.listenView).mas_offset(-15);
        make.left.equalTo(self.listenView).mas_offset(10);
        make.right.equalTo(self.listenView).mas_offset(-10);
    }];
    
    WEAKSELF
    self.voicePlayView.playClick = ^(BOOL boolValue) {
        if (boolValue == YES) {
            [weakSelf play];
        } else {
            [weakSelf stop];
        }
    };

    [self.view addSubview:self.alertView];
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view insertSubview:self.micInputAnimationView atIndex:0];
    [self.micInputAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.recordButton);
        make.width.height.equalTo(self.recordButton);
    }];
    
    self.taskNameLabel.text = self.taskListModel.title;
    self.taskIdLabel.text = [NSString stringWithFormat:@"PoID:%@", self.taskListModel.task_no];

    // 1: 试做题目 2：正式题目
    NSInteger topic_type = 0;
    if (self.taskListModel.is_try == 0) {
        // 任务为不需要试做时 获取正式题目
        topic_type = 2;
    } else if (self.taskListModel.is_try == 1 && self.taskListModel.try_status == 1) {
        // 任务为需要试做且试做通过时 获取正式题目
        topic_type = 2;
    } else {
        // 其他都加载试做题目
        topic_type = 1;
    }
    
    // 加载题目列表
    [[MONetDataServer sharedMONetDataServer] getUserTaskTopicWithTaskId:self.taskListModel.task_id user_task_id:self.taskListModel.user_task_id task_status:self.task_status topic_type:topic_type success:^(NSDictionary *dic) {
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
			self.selectQuestionLimitIndex = self.currentQuestionIndex;
            [self reloadUI];
        } else {
            self.currentQuestionIndex = 0;
			self.selectQuestionLimitIndex = questionDetail.count;
            [self reloadUI];
        }

    } failure:^(NSError *error) {
        [MBProgressHUD showMessag:error.localizedDescription toView:MOAppDelegate.window];
    } msg:^(NSString *string) {
        [MBProgressHUD showMessag:string toView:MOAppDelegate.window];
    } loginFail:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self hidenActivityIndicator];
		});
    }];
        
    [self.alertView setTaskRequirement:self.taskListModel.recording_requirements];
    
    if (self.taskListModel.is_need_describe == 1) {
        self.inputTextLabel.hidden = NO;
        self.inputView.hidden = NO;
        self.inputTextView.zw_placeHolder = NSLocalizedString(@"请输入文本内容...", nil);
        self.inputTextView.zw_placeHolderColor = [BlackColor colorWithAlphaComponent:0.3];
        self.inputTextView.delegate = self;
    } else {
        self.inputTextLabel.hidden = YES;
        self.inputView.hidden = YES;
    }
    
    self.mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    NSString *newTitile = self.taskListModel.is_follow == 1?NSLocalizedString(@"取消关注",nil):NSLocalizedString(@"+关注",nil);
    [self.followButton setTitles:newTitile];
    
    [self.view addSubview:self.blurEffectView];
    self.blurEffectView.hidden = YES;
    [self.blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.questionListStateView cornerRadius:QYCornerRadiusBottom radius:16];
}

#pragma mark - UITextViewDelegate

#pragma mark - record methods

- (NSString *)getTaskVoiceFolderPath {
    // 获取Cache文件目录
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [directoryPaths objectAtIndex:0];
    
    // 获取录音文件目录
    NSString *recordFolderPath = [cachesDirectory stringByAppendingFormat:@"/Mobiwusi/recordTask/"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //如果录音文件目录不存在，创建新的录音文件目录
    if (![fileManager fileExistsAtPath:recordFolderPath]) {
        [fileManager createDirectoryAtPath:recordFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return recordFolderPath;
}

- (NSString *)getTaskVoiceFilePathWithFileName:(NSString *)fileName {
    //录音文件夹路径
    NSString *folderPath = [self getTaskVoiceFolderPath];
    //录音文件路径
    NSString *recordFilePath = [folderPath stringByAppendingFormat:@"%@",fileName];
    return recordFilePath;
}

#pragma mark - count down animations

- (void)createCountdownLabel {
    // 创建UILabel
    self.countdownLabel = [[UILabel alloc] init];
    self.countdownLabel.text = [NSString stringWithFormat:@"%ld", self.countdownValue];
    self.countdownLabel.font = [UIFont boldSystemFontOfSize:40];
    self.countdownLabel.textColor = [UIColor whiteColor];
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    self.countdownLabel.layer.backgroundColor = MainSelectColor.CGColor;  // 圆形背景色
    self.countdownLabel.layer.cornerRadius = 50;  // 圆角
    self.countdownLabel.layer.masksToBounds = YES; // 保证圆形裁剪
    self.countdownLabel.frame = CGRectMake(self.view.center.x - 50, self.view.center.y - 50, 100, 100);
    
    [self.blurEffectView.contentView addSubview:self.countdownLabel];
//    [self updateCountdown];
}

- (void)startCountdown {
    // 定时器每秒触发一次倒计时
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats:NO];
//    [self.timer fire];
    self.blurEffectView.hidden = NO;
    [self updateCountdown];
}


- (void)updateCountdown {
    // 使用渐显动画显示数字
    
    WEAKSELF
    [self countdownLabelAnimateWithCompletion:^(BOOL finished) {
        
        weakSelf.countdownLabel.text = @"GO";
        [weakSelf countdownLabelAnimateWithCompletion:^(BOOL finished) {
            weakSelf.blurEffectView.hidden = YES;
            [weakSelf.countdownLabel removeFromSuperview];
            weakSelf.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                   target:self
                                                                 selector:@selector(updateAudioMeter)
                                                                 userInfo:nil
                                                                  repeats:YES];
        }];
    }];
    
    return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [UIView animateWithDuration:0.5 animations:^{
        self.countdownLabel.alpha = 1.0;  // 渐显
    } completion:^(BOOL finished) {
        // 在显示数字的同时，开始延时消失
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
            self.countdownLabel.alpha = 0.0;  // 渐隐
        } completion:^(BOOL finished) {
            // 更新数字，准备显示下一个数字
            if (self.countdownValue > 0) {
                self.countdownLabel.text = [NSString stringWithFormat:@"%ld", self.countdownValue];
            } else {
                CFTimeInterval endTime = CACurrentMediaTime();
                CFTimeInterval executionTime = endTime - startTime;
                self.countdownLabel.text = @"GO";
                DLog(@"GOGOGOGOGOGOGOGOGOGOGOGOGOGOGOGO");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.blurEffectView.hidden = YES;
                    
                });
                
                
            }
        }];
    }];
    
    // 更新倒计时值
    if (self.countdownValue > 0) {
        self.countdownValue-=1;
        
    } else {
        
    }
    
    // 启动定时器检测音量
    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(updateAudioMeter)
                                                         userInfo:nil
                                                          repeats:YES];
    // 当倒计时完成，停止定时器
    [self.timer invalidate];
    self.timer = nil;
    
    // 使用渐隐动画消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.countdownLabel removeFromSuperview];  // 移除倒计时标签
    });
}

-(void)countdownLabelAnimateWithCompletion:(void(^)(BOOL finished))completion {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.countdownLabel.alpha = 1.0;  // 渐显
    } completion:^(BOOL finished) {
        // 在显示数字的同时，开始延时消失
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
            self.countdownLabel.alpha = 0.0;  // 渐隐
        } completion:completion];
    }];
}

#pragma mark - UI

- (void)reloadUI {
    
    
    
    if (self.questionDetail.data.count > self.currentQuestionIndex) {
        self.currentQuestion = self.questionDetail.data[self.currentQuestionIndex];
        if (self.currentQuestion.audio_data.count > 0) {
            NSString *audio_play_url = self.currentQuestion.audio_data[0].url;
            [self.voicePlayView configWithUrl:audio_play_url andDuration:self.currentQuestion.audio_data[0].duration];
            self.urlString = audio_play_url;
            self.audioDuration = self.currentQuestion.audio_data[0].duration;
        }
    }
    
    if (self.currentQuestion.status == 0 || self.currentQuestion.status == 3) {
        self.inputTextView.editable = YES;
    } else {
        self.inputTextView.editable = NO;
    }
    
    [self.questionListStateView configViewWithQuestionList1:self.questionDetail.data selectedIndex:self.currentQuestionIndex taskModel1:self.taskListModel];
    
	WEAKSELF
	self.questionListStateView.didClickNewIndex = ^(NSInteger index) {
		if (index > weakSelf.selectQuestionLimitIndex) {
			return;
		}
		
		weakSelf.currentQuestionIndex = index;
		[weakSelf reloadUI];
		
	};
	
    self.inputTextView.text = self.currentQuestion.text_data;
    
    self.questionNumberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.currentQuestionIndex+1), (long)self.questionDetail.count];
    self.readTextLabel.text = self.currentQuestion.text;
    if (self.currentQuestion.demand.isExist) {
        self.taskRequireTv.text = self.currentQuestion.demand;
    } else {
        self.taskRequireTv.text = self.taskListModel.recording_requirements;
    }
    
    self.previewButton.hidden = NO;
    self.nextButton.hidden = NO;
    if (self.currentQuestionIndex > 0) {
        self.previewButton.alpha = 1;
    } else {
        self.previewButton.alpha = 0.5;
    }
    
    if (self.currentQuestionIndex < self.questionDetail.count-1) {
        self.nextButton.alpha = 1;
    } else {
        self.nextButton.alpha = 0.5;
    }
    
    switch (self.currentQuestion.status) {
        case 0:
        {
            // 未录制
            self.reasonView.hidden = YES;
            self.reasonViewHeight.constant = 0;
            self.titleTop.constant = 8;
            
            self.step3Label.hidden = NO;
            self.recordButton.hidden = NO;
            self.micInputAnimationView.hidden = NO;
            if (self.currentQuestion.ex_url.isExist) {
                self.samplePlayButton.hidden = NO;
            }
            
            self.step4Label.hidden = YES;
            self.listenView.hidden = YES;
            
            self.step5Label.hidden = YES;
            self.bottomView.hidden = YES;
            self.bottomHeight.constant = 92.f;
            self.step5Label.text = NSLocalizedString(@"Step5：确认数据", nil);
            self.inputViewTopMargin.constant = 15;
        }
            break;
        case 1:
        {
            // 待审核
            self.reasonView.hidden = YES;
            self.reasonViewHeight.constant = 0;
            self.titleTop.constant = 8;
            
			self.step3Label.hidden = YES;
			self.recordButton.hidden = YES;
			self.micInputAnimationView.hidden = YES;
			self.samplePlayButton.hidden = YES;
            
            self.step4Label.hidden = NO;
            self.listenView.hidden = NO;
            
            self.step5Label.hidden = YES;
            self.bottomView.hidden = YES;
            self.bottomHeight.constant = 0.f;
            self.step5Label.text = @"";
            self.inputViewTopMargin.constant = 145;
            
        }
            break;
        case 2:
        {
            // 通过
            self.reasonView.hidden = YES;
            self.reasonViewHeight.constant = 0;
            self.titleTop.constant = 8;
            
            self.step3Label.hidden = YES;
            self.recordButton.hidden = YES;
            self.micInputAnimationView.hidden = YES;
            self.samplePlayButton.hidden = YES;
            
            self.step4Label.hidden = NO;
            self.listenView.hidden = NO;

            self.step5Label.hidden = YES;
            self.bottomView.hidden = YES;
            self.bottomHeight.constant = 0.f;
            self.step5Label.text = @"";
            
            self.inputViewTopMargin.constant = 145;
            
        }
            break;
        case 3:
        {
            // 不通过
            self.reasonView.hidden = NO;
            NSString *reason = [NSString stringWithFormat:@"reason:%@",self.currentQuestion.audio_data.firstObject.remark?: self.currentQuestion.remark];
            self.reasonLabel.text = reason;
            CGSize size = [Util calculateLabelSizeWithText:reason andMarginSize:CGSizeMake(SCREEN_WIDTH-40, CGFLOAT_MAX) andTextFont:[UIFont systemFontOfSize:12]];
            self.reasonViewHeight.constant = size.height+40;
            self.titleTop.constant = 15;
            
            self.step3Label.hidden = NO;
            self.recordButton.hidden = NO;
            self.micInputAnimationView.hidden = NO;
            
            if (self.currentQuestion.ex_url.isExist) {
                self.samplePlayButton.hidden = NO;
            }
            
            self.step4Label.hidden = NO;
            self.listenView.hidden = NO;
            
            self.step5Label.hidden = YES;
            self.bottomView.hidden = YES;
            self.bottomHeight.constant = 92.f;
            self.step5Label.text = NSLocalizedString(@"Step5：确认数据", nil);
            
            self.inputViewTopMargin.constant = 145;
            
        }
            break;
        default:
            break;
    }
    
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
    [self.progressTimer invalidate];
}

#pragma mark - actions

- (IBAction)myAudioClick:(id)sender {
	
	MOMyAudioDataVC *vc = [[MOMyAudioDataVC alloc] initWithCate:1 userTaskId:self.taskListModel.user_task_id user_paste_board:NO];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
}

- (IBAction)followClick:(id)sender {
    
    if (self.taskListModel.is_follow) {
        WEAKSELF
        [MOMsgAlertView showWithTitle:NSLocalizedString(@"温馨提示", nil) andMsg:NSLocalizedString(@"确定要取消关注吗?", nil) andSureClickHandle:^{
            [weakSelf requestFollowTask];
        }];
    } else {
        [self requestFollowTask];
    }
}

-(void)requestFollowTask {
    
    NSInteger action = self.taskListModel.is_follow == 1?2:1;
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] followTaskWithTaskId:self.taskListModel.task_id action:action success:^(NSInteger index) {
        [self hidenActivityIndicator];
        [self showMessage:NSLocalizedString(@"操作成功",nil)];
        self.taskListModel.is_follow = self.taskListModel.is_follow == 1?0:1;
        NSString *newTitile = self.taskListModel.is_follow == 1?NSLocalizedString(@"取消关注",nil):NSLocalizedString(@"+关注",nil);
        [self.followButton setTitles:newTitile];
        
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

- (IBAction)viewRequirementClick:(id)sender {
    self.alertView.hidden = NO;
}

- (IBAction)backClick:(id)sender {
    [self goBack];
}

- (IBAction)previewClick:(id)sender {

    if (self.currentQuestionIndex > 0) {
        self.currentQuestionIndex -= 1;
        [self reloadUI];
    }
    
}

- (IBAction)nextClick:(id)sender {
    
    if (self.currentQuestion.audio_data.count == 0) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请先录制声音", nil) toView:MOAppDelegate.window];
        return;
    }
    
    if (self.currentQuestionIndex < self.questionDetail.count-1) {
        self.currentQuestionIndex += 1;
		self.selectQuestionLimitIndex = self.currentQuestionIndex;
        [self reloadUI];
    } else {
        
        if (self.taskStatusChangeed) {
            self.taskStatusChangeed(2);
        }
        [self goBack];
    }
    
}

- (IBAction)audioPlayClick:(id)sender {
//    self.audioPlayButton.selected = !self.audioPlayButton.selected;
//    if (self.audioPlayButton.selected == YES) {
//        [self audioPlayerPlay:self.currentQuestion.result];
//    } else {
//        [self audioPlayerPasuse];
//    }
}

- (IBAction)sampleAudioClick:(id)sender {
    self.samplePlayButton.selected = !self.samplePlayButton.selected;
    if (self.samplePlayButton.selected == YES) {
        
    } else {
        
    }
}

- (IBAction)recordClick:(id)sender {
    
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (AVstatus == AVAuthorizationStatusDenied) {
        
        UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"请在\"设置－Mobiwusi\"中打开麦克风权限", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"去设置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
        }];
        // 添加操作
        [alertDialog addAction:sureAction];
        // 呈现警告视图
        [self presentViewController:alertDialog animated:YES completion:^{}];
        return ;
    } else if (AVstatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) { }];
        return;
    }
    
    self.recordButton.selected = !self.recordButton.selected;
    if (self.recordButton.selected == YES) {
        // 开始录制
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
        [[AVAudioSession sharedInstance] setPreferredSampleRate:44100 error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.wav", [NSUUID UUID].UUIDString];
        self.recordFileName = fileName;
        
        [self startRecordWithFileName:fileName];
        
        // 初始化倒计时的起始值
        self.countdownValue = 1;
        
        // 创建并设置倒计时标签
        [self createCountdownLabel];
        
        // 开始倒计时
        [self startCountdown];

        
    } else {
        // 停止录制
        [self finishRecorder];
    }
}

- (IBAction)againButtonClick:(id)sender {
    self.step3Label.hidden = NO;
    self.recordButton.hidden = NO;
    self.micInputAnimationView.hidden = NO;
    
    self.previewButton.hidden = NO;
    self.nextButton.hidden = NO;
    if (self.currentQuestionIndex > 0) {
        self.previewButton.alpha = 1;
    } else {
        self.previewButton.alpha = 0.5;
    }
    
    if (self.currentQuestionIndex < self.questionDetail.count-1) {
        self.nextButton.alpha = 1;
    } else {
        self.nextButton.alpha = 0.5;
    }
    
    self.inputViewTopMargin.constant = 15;
    if (self.currentQuestion.ex_url.isExist) {
        self.samplePlayButton.hidden = NO;
    } else {
        self.samplePlayButton.hidden = YES;
    }

    self.step4Label.hidden = YES;
    self.step5Label.hidden = YES;
    self.bottomView.hidden = YES;
    self.listenView.hidden = YES;
    
    self.previewButton.hidden = YES;
    self.nextButton.hidden = YES;
    
    [[NSFileManager defaultManager] removeItemAtPath:[self getTaskVoiceFilePathWithFileName:self.recordFileName] error:nil];
    self.recordFileName = @"";
}

- (IBAction)submitClick:(id)sender {
    NSString *textData = @"";
    if (self.taskListModel.is_need_describe == 1) {
        if (self.inputTextView.text.isExist == NO) {
            [MBProgressHUD showMessag:NSLocalizedString(@"请输入文本内容", nil) toView:MOAppDelegate.window];
            return;
        }
        textData = self.inputTextView.text;
    }
    
    NSString *audioPath = [self getTaskVoiceFilePathWithFileName:self.recordFileName];
    NSInteger audioDuration = [self getAudioDurationFromFile:audioPath];
    NSData *data = [NSData dataWithContentsOfFile:audioPath];
    /// 传字节数
    NSInteger length = data.length;
    MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
    NSInteger data_id = 0;
    if (self.currentQuestion.audio_data.count > 0) {
        if (self.currentQuestion.audio_data[0].model_id > 0) {
            data_id = self.currentQuestion.audio_data[0].model_id;
        }
    }
    
    [[MONetDataServer sharedMONetDataServer] uploadAudioFileWithFileName:self.recordFileName filePath:[self getTaskVoiceFilePathWithFileName:self.recordFileName] success:^(NSDictionary *dic) {
        NSString *relate_url = dic[@"relative_url"];
        NSString *url = dic[@"url"];
        
        NSDictionary *audio_dict = @{
            @"id":@(data_id),
            @"file_name":self.recordFileName?:@"",
            @"duration":@(audioDuration),
            @"format":@"WAV",
            @"size":@(length),
            @"url":relate_url,
            @"rate":@"44100"
        };
        NSArray *audio_data = @[audio_dict];
        
        [[MONetDataServer sharedMONetDataServer] finishTopicWithTaskId:self.taskListModel.task_id user_task_id:self.taskListModel.user_task_id result_id:self.currentQuestion.model_id text_data:textData picture_data:nil audio_data:[audio_data yy_modelToJSONString] file_data:nil video_data:nil success:^(NSDictionary *dic) {
            [hud hide:YES];
                                    
            self.currentQuestion.result = url;
            self.currentQuestion.status = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:CompletedOneTopic object:nil userInfo:@{@"currentQuestionIndex":@(self.currentQuestionIndex)}];
            MOTaskQuestionDataModel *model = [MOTaskQuestionDataModel new];
            model.duration = audioDuration;
            model.url = url;
            model.file_name = self.recordFileName;
            model.cate = 1;
			model.status = 1;
            self.currentQuestion.audio_data = @[model];
			self.currentQuestion.text_data = textData;
            [self nextClick:nil];
			
            
        } failure:^(NSError *error) {
            [hud hide:YES];
            [MBProgressHUD showMessag:error.localizedDescription toView:MOAppDelegate.window];
        } msg:^(NSString *string) {
            [hud hide:YES];
            [MBProgressHUD showMessag:string toView:MOAppDelegate.window];
        } loginFail:^{
            [hud hide:YES];
        }];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [MBProgressHUD showMessag:error.localizedDescription toView:MOAppDelegate.window];
        
    } loginFail:^{
        [hud hide:YES];
    }];
    
}

- (NSInteger)getAudioDurationFromFile:(NSString *)filePath {
    // 创建音频文件的 AVAsset 实例
    NSURL *audioURL = [NSURL fileURLWithPath:filePath];
    AVAsset *asset = [AVAsset assetWithURL:audioURL];
    
    // 获取音频时长（单位：秒）
    CMTime duration = asset.duration;
    CGFloat durationInSeconds = 1000*CMTimeGetSeconds(duration);
    
    // 将时长转换为整数（舍去小数部分）
    NSInteger durationInInteger = (NSInteger)durationInSeconds;
    
    return durationInInteger;
}

- (void)startRecordWithFileName:(NSString *)fileName {
    NSString *recordFilePath = [self getTaskVoiceFilePathWithFileName:fileName];
    DLog(@"recordFilePath - %@",recordFilePath);

    NSDictionary *recordSetting = @{
        AVFormatIDKey: @(kAudioFormatLinearPCM),  // 使用无损 PCM 编码
        AVSampleRateKey: @44100,  // 设置采样率为 441 kHz
        AVNumberOfChannelsKey: @1,  // 单声道
        AVLinearPCMBitDepthKey: @16,  // 设置采样比特率为 16-bit
        AVLinearPCMIsFloatKey: @NO,  // 使用整数而非浮动数值
        AVLinearPCMIsBigEndianKey: @NO,  // 使用小端编码
        AVEncoderAudioQualityKey:@(AVAudioQualityHigh)
        
    };
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordFilePath] settings:recordSetting error:nil];
    self.recorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
    [self.recorder prepareToRecord];
    [self.recorder record];
    
}

- (void)finishRecorder {
    
    [self showProgressWithMessage:NSLocalizedString(@"保持静音，录音处理中", nil)];
    if([_recorder isRecording]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.levelTimer invalidate];
            self.levelTimer = nil;
            AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:[NSURL fileURLWithPath:[self getTaskVoiceFilePathWithFileName:self.recordFileName]] error:nil];
            DLog(@"Actual Sample Rate: %f", audioFile.fileFormat.sampleRate);
            
            [self.recorder stop];
            self.step3Label.hidden = YES;
            self.recordButton.hidden = YES;
            self.micInputAnimationView.hidden = YES;
            self.samplePlayButton.hidden = YES;
            
            self.step4Label.hidden = NO;
            self.step5Label.hidden = NO;
            self.bottomView.hidden = NO;
            self.listenView.hidden = NO;
            self.previewButton.hidden = NO;
            
            self.inputViewTopMargin.constant = 145;
            
            NSString *audioPath = [self getTaskVoiceFilePathWithFileName:self.recordFileName];
            /// 毫秒
            NSInteger audioDuration = [self getAudioDurationFromFile:audioPath];
            
            [self.voicePlayView configWithUrl:audioPath andDuration:audioDuration];
            
            self.urlString = audioPath;
            self.audioDuration = audioDuration;
            if (self.currentQuestionIndex == self.questionDetail.count-1) {
                [self.submitButton setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
                self.nextButton.hidden = YES;
            } else {
                [self.submitButton setTitle:NSLocalizedString(@"录制下一条", nil) forState:UIControlStateNormal];
                self.nextButton.hidden = NO;
            }
            
        });
    }
    
}

- (void)updateAudioMeter {
    [self.recorder updateMeters]; // 更新音量数据
    // 获取分贝值 (通道0)
    float decibels = [self.recorder averagePowerForChannel:0];
    // 将分贝值归一化到 0-1 范围
    float normalizedValue = (decibels + 160.0) / 160.0;
    normalizedValue = MAX(0.0, MIN(1.0, normalizedValue)); // 确保值在0到1之间

    DLog(@"normalizedValue - %f", normalizedValue);
    [self.micInputAnimationView updateMeters:normalizedValue*0.5];
    
}

- (void)play {
    if ([self isDeviceMuted] == YES) {
        [MBProgressHUD showMessag:NSLocalizedString(@"当前音量过小，请调大音量后播放", nil) toView:MOAppDelegate.window];
    }
//    [self.delegate audioPlayerCellDidRequestPlay:self]; // 请求播放，交给ViewController管理
    [self startPlaying];
}

- (void)startPlaying {
    // 实际开始播放的逻辑
    NSURL *audioURL = [self.urlString hasPrefix:@"http"] ? [NSURL URLWithString:self.urlString] : [NSURL fileURLWithPath:self.urlString];
    self.isLocalAudio = ![self.urlString hasPrefix:@"http"];
    
    NSError *error;
    if (self.isLocalAudio) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        if (error) {
            DLog(@"本地音频初始化失败: %@", error.localizedDescription);
            return;
        }
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target:self
                                                            selector:@selector(updateLocalAudioProgress)
                                                            userInfo:nil
                                                             repeats:YES];
    } else {
        self.avPlayer = [[AVPlayer alloc] initWithURL:audioURL];
        [self.avPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        __weak typeof(self) weakSelf = self;
        [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                                    queue:dispatch_get_main_queue()
                                               usingBlock:^(CMTime time) {
            [weakSelf updateNetworkAudioProgress];
        }];
        
        // 添加播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.avPlayer.currentItem];
        
        [self.avPlayer play];
    }
}

- (void)pause {
    if (self.isLocalAudio) {
        [self.audioPlayer pause];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    } else {
        [self.avPlayer pause];
    }
}

- (void)stop {
    if (self.isLocalAudio) {
        [self.audioPlayer stop];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        self.audioPlayer = nil;
    } else if (self.avPlayer) {
        [self.avPlayer pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                                              object:self.avPlayer.currentItem];
        @try {
            [self.avPlayer removeObserver:self forKeyPath:@"status"];
        } @catch (NSException *exception) {
            DLog(@"移除观察者失败: %@", exception);
        }
        self.avPlayer = nil;
    }
}

- (void)updatePlayingState:(BOOL)isPlaying {
    if (isPlaying) {
        [self startPlaying];
    } else {
        [self stop];
    }
}

#pragma mark - Progress Updates

- (void)updateLocalAudioProgress {
    if (self.audioPlayer.isPlaying) {
        float progress = self.audioPlayer.currentTime / (self.audioDuration/1000.f);
        [self.voicePlayView updatePlayProgress:progress andCurrentTime:self.audioPlayer.currentTime];
    }
}

- (void)updateNetworkAudioProgress {
    if (self.avPlayer.rate > 0 && self.avPlayer.error == nil) {
        CMTime currentTime = self.avPlayer.currentTime;
//        DLog(@"currentTime - %f", CMTimeGetSeconds(currentTime));
        float progress = CMTimeGetSeconds(currentTime) / (self.audioDuration/1000.f);
        [self.voicePlayView updatePlayProgress:progress andCurrentTime:CMTimeGetSeconds(currentTime)];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.voicePlayView endPlay];
    [self stop];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.voicePlayView endPlay];
    [self stop];
}

#pragma mark - AVPlayer Notification

- (void)playerItemDidFinishPlaying:(NSNotification *)notification {
    DLog(@"网络音频播放完成");
    [self.voicePlayView endPlay];
    [self stop];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.avPlayer.status) {
            case AVPlayerStatusReadyToPlay:
//                [self startPlaying];
                break;
            case AVPlayerStatusFailed:
//                [self stop];
                break;
            case AVPlayerStatusUnknown:
//                [self stop];
                break;
        }
    }
}

- (MORecordTaskAlertView *)alertView {
    if (_alertView == nil) {
        _alertView = [[[NSBundle mainBundle]loadNibNamed:@"MORecordTaskAlertView" owner:nil options:nil] lastObject];
    }
    return _alertView;
}

- (MOMicAnimationView *)micInputAnimationView {
    if (_micInputAnimationView == nil) {
        _micInputAnimationView = [MOMicAnimationView new];
        _micInputAnimationView.borderColor = [UIColor colorWithHexString:@"EDDEE0"];
        _micInputAnimationView.innercircleColor = [UIColor colorWithHexString:@"EDDEE0"];
    }
    return _micInputAnimationView;
}

- (MOVoicePlayView *)voicePlayView {
    if (_voicePlayView == nil) {
        _voicePlayView = [MOVoicePlayView new];
    }
    return _voicePlayView;
}

#pragma mark - Audio State Checks

- (BOOL)isDeviceMuted {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 确保音频会话已激活并设置为播放模式
    NSError *error;
    if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback]) {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error) {
            NSLog(@"设置音频会话类别失败: %@", error.localizedDescription);
            return NO; // 默认返回非静音，防止误判
        }
    }
    [audioSession setActive:YES error:nil];
    
    // 获取当前音频路由
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    
    // 如果没有输出设备（例如拔掉耳机后无扬声器输出），认为是静音
    if (currentRoute.outputs.count == 0) {
        NSLog(@"无音频输出设备");
        return YES;
    }
    
    // 检查输出设备类型
    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        // 如果是内置扬声器
        if ([output.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            float volume = audioSession.outputVolume; // 范围 0.0 - 1.0
            NSLog(@"当前音量: %.2f", volume);
            // 如果音量为0，且使用扬声器，通常是静音开关打开
            return (volume == 0.0);
        }
        // 如果是耳机、蓝牙等外部设备，静音开关不影响输出
        else if ([output.portType isEqualToString:AVAudioSessionPortHeadphones] ||
                 [output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            return NO; // 耳机模式下，静音开关无效
        }
    }
    
    // 默认返回NO（非静音）
    return NO;
}

-(UIVisualEffectView *)blurEffectView {
    
    if (!_blurEffectView) {
        UIBlurEffect *effrct = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effrct];
    }
    return _blurEffectView;
}

@end
