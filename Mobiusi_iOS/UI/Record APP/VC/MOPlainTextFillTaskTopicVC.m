//
//  MOPlainTextFillTaskTopicVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOPlainTextFillTaskTopicVC.h"

#import "MOTextFillTaskUploadPlaceholderCell.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "MOAttchmentFileInfoModel.h"
#import "MOTextFillTaskUploadFileCell.h"
#import "NSObject+KVO.h"
#import "MOUploadFileDataModel.h"
#import "MOMyTextDataVC.h"
#import "MOPlainTextFillTaskStep2View.h"
#import <UITextView+ZWPlaceHolder.h>

@interface MOPlainTextFillTaskTopicVC ()
@property(nonatomic,strong)MOPlainTextFillTaskStep2View *step2View;
@end

@implementation MOPlainTextFillTaskTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.myDataBtn setTitles:NSLocalizedString(@"我的文本",nil)];
    
    WEAKSELF
    self.didMyDataBtnClick = ^{
        MONavigationController *nav = [MOMyTextDataVC creatPresentationCustomStyleWithNavigationRootVCWithCate:3 userTaskId:weakSelf.taskModel.user_task_id];
        [MOAppDelegate.transition.topViewController presentViewController:nav animated:YES completion:NULL];
    };
}




-(void)configUIAfterReceivingData {
    [super configUIAfterReceivingData];
    
    WEAKSELF
    self.step1View.titleLabel.text = StringWithFormat(@"Step1：%@",NSLocalizedString(@"阅读文本要求", nil));
    self.step2View.exampleBtn.hidden = [self.taskModel.example_url length] == 0;
    self.step2View.didExampleBtnClick = ^{
        
        [MOWebViewController pushWebVCWithUrl:weakSelf.taskModel.example_url title:NSLocalizedString(@"样例", nil)];
    };
    [self.scrollContentView addSubview:self.step2View];
    MOTaskQuestionModel *questionMode = nil;
    if (self.questionDetail.data.count-1 >= self.currentQuestionIndex) {
        questionMode = self.questionDetail.data[self.currentQuestionIndex];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        if (weakSelf.step2View.textInput == notification.object) {
            if ([weakSelf.step2View.textInput.text length] &&
                [weakSelf.step2View.titleInput.text length]) {
                
                [weakSelf showBottomView];
            } else {
                [weakSelf hiddenBottomView];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        if (weakSelf.step2View.titleInput == notification.object) {
//            if (weakSelf.step2View.titleInput.text.length >20) {
//                weakSelf.step2View.titleInput.text = [weakSelf.step2View.titleInput.text substringToIndex:20];
//            }
//            weakSelf.step2View.titleLengthCountLabel.text = [NSString stringWithFormat:@"%ld/20",weakSelf.step2View.titleInput.text.length];
            
            if ([weakSelf.step2View.textInput.text length] &&
                [weakSelf.step2View.titleInput.text length]) {
                
                [weakSelf showBottomView];
            } else {
                [weakSelf hiddenBottomView];
            }
        }
    }];

    
    MOTaskQuestionDataModel *fileData = questionMode.file_data.firstObject;
    
    self.step2View.textInput.editable = [self canEdit];
    self.step2View.titleInput.enabled = [self canEdit];
    self.step2View.titleInput.text = @"";
    self.step2View.titleLengthCountLabel.text = @"";
    self.step2View.textInput.text = @"";
	self.step2View.textInput.placeholder = NSLocalizedString(@"请输入文本内容...", nil);
    if (fileData) {
        NSString *title = [fileData.file_name stringByReplacingOccurrencesOfString:@".txt" withString:@""];
        self.step2View.titleInput.text = title;
//        self.step2View.titleLengthCountLabel.text = [NSString stringWithFormat:@"%lu/20",(unsigned long)title.length];
        self.step2View.textInput.placeholder = NSLocalizedString(@"加载中...", nil);
         
        dispatch_async(dispatch_queue_create("requestOnlineText", DISPATCH_QUEUE_CONCURRENT), ^{
            
            NSString *text = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fileData.url?:@""] encoding:NSUTF8StringEncoding error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.step2View.textInput.text = text;
            });
            
            
        });
    }
    
    
    [self.step2View mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.scrollContentView.mas_left);
        make.right.equalTo(self.scrollContentView.mas_right);
        make.top.equalTo(self.step1View.mas_bottom).offset(11);
        make.bottom.equalTo(self.scrollContentView.mas_bottom);
    }];
    

}

-(void)submitData {
    
    
    WEAKSELF
    [self showActivityIndicator];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("uploadFile", DISPATCH_QUEUE_CONCURRENT);
    
    NSString *title = weakSelf.step2View.titleInput.text;
    NSString *textStr = weakSelf.step2View.textInput.text;
    MOUploadFileDataModel *dataModel  = [MOUploadFileDataModel new];
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        
        NSString *mineType = @"text/plain";
        NSString *fileName = [NSString stringWithFormat:@"%@.txt",title];
        NSData *textData = [textStr dataUsingEncoding:NSUTF8StringEncoding];
        MOTaskQuestionModel* questionModel = self.questionDetail.data[self.currentQuestionIndex];
        MOTaskQuestionDataModel *fileData = questionModel.file_data.firstObject;
        dataModel.model_id = fileData.model_id;
        dataModel.file_name = fileName;
        dataModel.size = [textData length];
        dataModel.format = @"text";
        
        [[MONetDataServer sharedMONetDataServer] uploadFileWithFileName:fileName fileData:textData mimeType:mineType success:^(NSDictionary *dic) {
            dataModel.url = dic[@"relative_url"];
			dataModel.fullUrl = dic[@"url"];
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        } loginFail:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self hidenActivityIndicator];
			});
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
            
        NSMutableArray *json = @[].mutableCopy;
        [json addObject:dataModel];
        NSString *fileData = [json yy_modelToJSONString];
       
        MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
        [[MONetDataServer sharedMONetDataServer] finishTopicWithTaskId:weakSelf.taskModel.task_id user_task_id:weakSelf.taskModel.user_task_id result_id:questionMode.model_id text_data:nil picture_data:nil audio_data:nil file_data:fileData video_data:nil success:^(NSDictionary *dic) {
            
            [weakSelf hidenActivityIndicator];
            questionMode.status = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:CompletedOneTopic object:nil userInfo:@{@"currentQuestionIndex":@(weakSelf.currentQuestionIndex)}];
            if (weakSelf.currentQuestionIndex + 1 == weakSelf.questionDetail.count) {
                weakSelf.taskModel.task_status = @(2);
                if (weakSelf.taskStatusChangeed) {
                    weakSelf.taskStatusChangeed(2);
                }
                [MOAppDelegate.transition popViewControllerAnimated:YES];
                return;
            }
			
			//还原数据，以方便点击查看刚提交的数据
			MOTaskQuestionDataModel *fileModel = [MOTaskQuestionDataModel new];
			fileModel.url = dataModel.fullUrl;
			fileModel.file_name = dataModel.file_name;
			fileModel.model_id = dataModel.model_id;
			fileModel.status = 1;
			fileModel.cate = 3;
			questionMode.file_data = @[fileModel];
            weakSelf.currentQuestionIndex += 1;
			weakSelf.selectQuestionLimitIndex = weakSelf.currentQuestionIndex;
			questionMode.text_data = nil;
            [weakSelf resetUI];
            
            DLog(@"%@",dic);
            
        } failure:^(NSError *error) {
            [weakSelf hidenActivityIndicator];
            [weakSelf showErrorMessage:error.localizedDescription];
        } msg:^(NSString *string) {
            [weakSelf hidenActivityIndicator];
            [weakSelf showErrorMessage:string];
        } loginFail:^{
            [weakSelf hidenActivityIndicator];
        }];
        
    });
}



-(void)resetUI {
    
    [self configUIAfterReceivingData];
}



#pragma mark - setter && getter
- (MOPlainTextFillTaskStep2View *)step2View {
    
    if (!_step2View) {
        _step2View = [MOPlainTextFillTaskStep2View new];
    }
    return _step2View;
}


@end
