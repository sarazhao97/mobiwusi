//
//  MOTextFillTaskTopicVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOTextFillTaskTopicVC.h"
#import "MOTextFillTaskUploadPlaceholderCell.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "MOAttchmentFileInfoModel.h"
#import "MOTextFillTaskUploadFileCell.h"
#import "NSObject+KVO.h"
#import "MOUploadFileDataModel.h"
#import "MOMyTextDataVC.h"
@interface MOTextFillTaskTopicVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIDocumentPickerDelegate>
@property(nonatomic,strong)MOTextFillTaskStep2View *step2View;
@property(nonatomic,strong)NSMutableArray<MOAttchmentFileInfoModel *> *atchmentDataList;
@property(nonatomic,assign)NSInteger replaceIndex;
@end

@implementation MOTextFillTaskTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.myDataBtn setTitles:NSLocalizedString(@"我的文本",nil)];
    WEAKSELF;
    self.didMyDataBtnClick = ^{
        
        MONavigationController *nav = [MOMyTextDataVC creatPresentationCustomStyleWithNavigationRootVCWithCate:3 userTaskId:weakSelf.taskModel.user_task_id];
        [MOAppDelegate.transition.topViewController presentViewController:nav animated:YES completion:NULL];
        
    };
}



-(void)configUIAfterReceivingData {
    [super configUIAfterReceivingData];
    self.replaceIndex = -1;
    WEAKSELF
    self.step1View.titleLabel.text = NSLocalizedString(@"Step1：阅读文本要求", nil);
    
    self.step2View.didExampleBtnClick = ^{
        
        [MOWebViewController pushWebVCWithUrl:weakSelf.taskModel.example_url title:NSLocalizedString(@"样例", nil)];
    };
    [self.scrollContentView addSubview:self.step2View];
    [self.step2View configUIWithModel:self.taskModel];
    self.step2View.attchmentCollectionView.delegate = self;
    self.step2View.attchmentCollectionView.dataSource = self;
    [self.step2View.attchmentCollectionView registerClass:[MOTextFillTaskUploadPlaceholderCell class] forCellWithReuseIdentifier:@"MOTextFillTaskUploadPlaceholderCell"];
    [self.step2View.attchmentCollectionView registerClass:[MOTextFillTaskUploadFileCell class] forCellWithReuseIdentifier:@"MOTextFillTaskUploadFileCell"];
    MOTaskQuestionModel *questionMode = nil;
    if (self.questionDetail.data.count-1 >= self.currentQuestionIndex) {
        questionMode = self.questionDetail.data[self.currentQuestionIndex];
    }
    [[self mutableArrayValueForKey:@"atchmentDataList"] removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        if (weakSelf.step2View.textInput == notification.object) {
            if ([weakSelf.step2View.textInput.text length] && weakSelf.taskModel.limit_of_one_upload_file == weakSelf.atchmentDataList.count) {
                
                [weakSelf showBottomView];
            } else{
                [weakSelf hiddenBottomView];
            }
        }
    }];
    
    [self observeValueForKeyPath:@"atchmentDataList" chnageBlck:^(NSDictionary * _Nonnull change, id  _Nonnull object) {
        
        if (![weakSelf canEdit]) {
            [weakSelf showBottomView];
            return;
        }
        if (weakSelf.step2View.textInput && [weakSelf.step2View.textInput.text length] && weakSelf.taskModel.limit_of_one_upload_file == weakSelf.atchmentDataList.count) {
            [weakSelf showBottomView];
        } else if(!weakSelf.step2View.textInput && weakSelf.taskModel.limit_of_one_upload_file == weakSelf.atchmentDataList.count) {
            [weakSelf showBottomView];
        } else {
            [weakSelf hiddenBottomView];
        }
    }];
    for (MOTaskQuestionDataModel *model in questionMode.file_data) {
        MOAttchmentFileInfoModel *attchModel = [MOAttchmentFileInfoModel new];
        attchModel.fileId = model.model_id;
        attchModel.fileName = model.file_name;
        attchModel.fileExtension = model.url.pathExtension;
        attchModel.fileServerUrl = model.url;
        attchModel.fileStatus = model.status;
        attchModel.errorMsg = model.remark;
        [[self mutableArrayValueForKey:@"atchmentDataList"] addObject:attchModel];
    }
    
    [weakSelf.step2View.attchmentCollectionView reloadData];
    
    self.step2View.textInput.text = questionMode.text_data?:@"";
    self.step2View.textInput.editable = [self canEdit];
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
    __block BOOL uploadFail = NO;
    __block BOOL unmode = NO;
    for (MOAttchmentFileInfoModel *model in weakSelf.atchmentDataList) {
        
        if ((model.fileStatus == 0 || model.fileStatus == 3) && model.fileData) {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                
                NSString *mineType = @"";
                if ([[model.fileName pathExtension] containsString:@".doc"]) {
                    mineType = @"application/msword";
                }
                if ([[model.fileName pathExtension] containsString:@".docx"]) {
                    mineType = @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                }
                if ([[model.fileName pathExtension] containsString:@".txt"]) {
                    mineType = @"text/plain";
                }
                [[MONetDataServer sharedMONetDataServer] uploadFileWithFileName:model.fileName fileData:model.fileData mimeType:mineType success:^(NSDictionary *dic) {
                    model.fileServerRelativeUrl = dic[@"relative_url"];
                    model.fileServerUrl = dic[@"url"];
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    uploadFail = YES;
                    dispatch_group_leave(group);
                } loginFail:^{
					dispatch_async(dispatch_get_main_queue(), ^{
						[self hidenActivityIndicator];
					});
                    uploadFail = YES;
                    dispatch_group_leave(group);
                }];
            });
        }
        
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        
        
        if (uploadFail) {
            [weakSelf hidenActivityIndicator];
            [weakSelf showErrorMessage:NSLocalizedString(@"文件上传失败", nil)];
            return;
        }
        
        NSString *fileJsonString = nil;
        if (weakSelf.taskModel.limit_of_one_upload_file > 0 ) {
            
            NSMutableArray *json = @[].mutableCopy;
            for (MOAttchmentFileInfoModel *model in weakSelf.atchmentDataList) {
                
                if ((model.fileStatus == 0 || model.fileStatus == 3) && model.fileServerRelativeUrl.length) {
                    MOUploadFileDataModel *dataModel  = [MOUploadFileDataModel new];
                    dataModel.model_id = model.fileId;
                    dataModel.file_name = model.fileName;
                    dataModel.size = [model.fileData length];
                    dataModel.url = model.fileServerRelativeUrl;
                    dataModel.format = model.fileExtension;
                    [json addObject:dataModel];
                }
                
            }
            fileJsonString = [json yy_modelToJSONString];
        }
        NSString *textData = nil;
        if (weakSelf.taskModel.is_need_describe) {
            textData = weakSelf.step2View.textInput.text;
        }
        
        
       
        MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
        [[MONetDataServer sharedMONetDataServer] finishTopicWithTaskId:weakSelf.taskModel.task_id user_task_id:weakSelf.taskModel.user_task_id result_id:questionMode.model_id text_data:textData picture_data:nil audio_data:nil file_data:fileJsonString video_data:nil success:^(NSDictionary *dic) {
            
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
            weakSelf.currentQuestionIndex += 1;
			//还原数据，以方便点击查看刚提交的数据
			weakSelf.selectQuestionLimitIndex = weakSelf.currentQuestionIndex;
			NSMutableArray *file_data = @[].mutableCopy;
			for (MOAttchmentFileInfoModel *model in weakSelf.atchmentDataList) {
				MOTaskQuestionDataModel *fileModel = [MOTaskQuestionDataModel new];
				fileModel.model_id = model.fileId;
				fileModel.url = model.fileServerUrl;
				fileModel.cate = 3;
				fileModel.status = 1;
				fileModel.file_name = model.fileName;
				[file_data addObject:fileModel];
			}
			questionMode.file_data = file_data;
			questionMode.text_data = textData;
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    if (![self canEdit]) {
        return self.atchmentDataList.count;
    }
    if (self.atchmentDataList.count == self.taskModel.limit_of_one_upload_file) {
        
        return self.atchmentDataList.count;
    }
    return self.atchmentDataList.count + 1;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.atchmentDataList.count - 1 >= indexPath.item  && self.atchmentDataList.count != 0) {
        
        MOTextFillTaskUploadFileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOTextFillTaskUploadFileCell" forIndexPath:indexPath];
        MOAttchmentFileInfoModel *model = self.atchmentDataList[indexPath.item];
        cell.deleteBtn.hidden = !([self canSubmitData] && model.fileStatus == 0);
        [cell configCellWithModel:model];
        cell.failurePromptView.hidden = !([self.taskModel.task_status integerValue] == 3 && model.fileStatus == 3);
        WEAKSELF
        cell.didDeleteBtnClick = ^{
            
            [[weakSelf mutableArrayValueForKeyPath:@"atchmentDataList"] removeObjectAtIndex:indexPath.item];
            [weakSelf.step2View.attchmentCollectionView reloadData];
        };
        cell.didErrorIconClick = ^{
            
            weakSelf.replaceIndex = indexPath.item;
            NSArray<NSString *> *allowedTypes = @[@"com.microsoft.word.doc",@"com.microsoft.word.docx",@"public.content"];
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:allowedTypes inMode:UIDocumentPickerModeImport];
            documentPicker.allowsMultipleSelection = NO;
            documentPicker.delegate = weakSelf;
            documentPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
            documentPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:documentPicker animated:YES completion:NULL];
            
        };
        return cell;
        
    } else {
        MOTextFillTaskUploadPlaceholderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOTextFillTaskUploadPlaceholderCell" forIndexPath:indexPath];
        return cell;
    }
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.atchmentDataList.count == self.taskModel.limit_of_one_upload_file) {
        MOAttchmentFileInfoModel *model = self.atchmentDataList[indexPath.item];
        if (model.fileStatus != 3) {
            return;
        }
    }
    
    self.replaceIndex = indexPath.item;
    NSArray<NSString *> *allowedTypes = @[@"com.microsoft.word.doc",@"com.microsoft.word.docx",@"public.content"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:allowedTypes inMode:UIDocumentPickerModeImport];
    documentPicker.allowsMultipleSelection = NO;
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    documentPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:documentPicker animated:YES completion:NULL];
}



- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    
    NSURL *selectedFileURL = urls.firstObject;
    NSString *pathExtension =  selectedFileURL.path.pathExtension;
    NSString *fileName = selectedFileURL.path.lastPathComponent;
    if (!([self.taskModel.file_type containsString:pathExtension])) {
        
        [self showErrorMessage:NSLocalizedString(@"格式不支持", nil)];
    } else {
        
        MOAttchmentFileInfoModel *model = [MOAttchmentFileInfoModel new];
        model.fileName = fileName;
        model.fileExtension = pathExtension;
        model.fileData = [NSData dataWithContentsOfFile:selectedFileURL.path];
        //如果当前选择索引小于等于self.atchmentDataList.count - 1，说明是替换，否则是添加
        int fileCount = (int)(self.atchmentDataList.count - 1);
        if (self.replaceIndex <= fileCount) {
            
            MOAttchmentFileInfoModel *acttchModel = [[self mutableArrayValueForKeyPath:@"atchmentDataList"] objectAtIndex:self.replaceIndex];
            model.fileId = acttchModel.fileId;
            model.fileStatus = acttchModel.fileStatus;
            model.errorMsg = acttchModel.errorMsg;
            [[self mutableArrayValueForKeyPath:@"atchmentDataList"] replaceObjectAtIndex:self.replaceIndex withObject:model];
            
        } else {
            
            MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
            MOTaskQuestionDataModel *fileModel = questionMode.file_data[self.replaceIndex];
            model.fileId = fileModel.model_id;
            [[self mutableArrayValueForKeyPath:@"atchmentDataList"] addObject:model];
        }
        
        [self.step2View.attchmentCollectionView reloadData];
        
    }
}

#pragma mark - setter && getter

-(MOTextFillTaskStep2View *)step2View {
    
    if (!_step2View) {
        _step2View = [MOTextFillTaskStep2View new];
    }
    
    return _step2View;
}

-(NSMutableArray<MOAttchmentFileInfoModel *> *)atchmentDataList {
    
    if (!_atchmentDataList) {
        _atchmentDataList = @[].mutableCopy;
    }
    return _atchmentDataList;
}


@end
