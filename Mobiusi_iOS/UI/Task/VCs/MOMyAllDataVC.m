//
//  MOMyAllDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/5.
//

#import "MOMyAllDataVC.h"
#import "MOMyPictureScheduleCell.h"
#import "MOMyVideoScheduleCell.h"
#import "MOMyVideoScheduleCell.h"
#import "MOMyVoiceScheduleCell.h"
#import "MOMessageListVC.h"
#import "MOBrowseMediumVC.h"
#import "Mobiusi_iOS-Swift.h"
@interface MOMyAllDataVC ()<MOMyVoiceScheduleCellDelegate>
@property (nonatomic, strong) NSIndexPath *currentPlayingIndexPath; // 当前播放的Cell的indexPath
@property(nonatomic,strong)MOButton *addTaskBtn;
@end

@implementation MOMyAllDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlimitedUploadDataUploadSuccess) name:@"UnlimitedUploadDataUploadSuccess" object:nil];
    self.navBar.titleLabel.text = NSLocalizedString(@"我的数据", nil);
	if (!self.user_paste_board) {
		[self.addTaskBtn addTarget:self action:@selector(addTaskBtnClick) forControlEvents:UIControlEventTouchUpInside];
		[self.navBar.rightItemsView addArrangedSubview:self.addTaskBtn];
	}
	
    [self.tableView registerClass:[MOMyTextScheduleCell class] forCellReuseIdentifier:@"MOMyTextScheduleCell"];
    [self.tableView registerClass:[MOMyPictureScheduleCell class] forCellReuseIdentifier:@"MOMyPictureScheduleCell"];
    [self.tableView registerClass:[MOMyVideoScheduleCell class] forCellReuseIdentifier:@"MOMyVideoScheduleCell"];
    [self.tableView registerClass:[MOMyVoiceScheduleCell class] forCellReuseIdentifier:@"MOMyVoiceScheduleCell"];
    [self.tableView registerClass:[MOBaseScheduleCell class] forCellReuseIdentifier:@"MOBaseScheduleCell"];
    
    [self.tableView registerClass:[MOSummarizeAudioInProcessCell class] forCellReuseIdentifier:@"MOSummarizeAudioInProcessCell"];
    [self.tableView registerClass:[MOSummarizeAudioFinishCell class] forCellReuseIdentifier:@"MOSummarizeAudioFinishCell"];
    [self.tableView registerClass:[MOSummarizeTextInProcessCell class] forCellReuseIdentifier:@"MOSummarizeTextInProcessCell"];
    [self.tableView registerClass:[MOSummarizeTextProcesFinishsCell class] forCellReuseIdentifier:@"MOSummarizeTextProcesFinishsCell"];
    [self.tableView registerClass:[MOSummarizeImageVideoInProcessCell class] forCellReuseIdentifier:@"MOSummarizeImageVideoInProcessCell"];
    [self.tableView registerClass:[MOSummarizeImageVideoFinishCell class] forCellReuseIdentifier:@"MOSummarizeImageVideoFinishCell"];
    [self.tableView registerClass:[MOSummarizeImageVideoInProcessCell class] forCellReuseIdentifier:@"MOSummarizeImageVideoInProcessCell"];
    [self.tableView registerClass:[MOSummarizeImageVideoFinishCell class] forCellReuseIdentifier:@"MOSummarizeImageVideoFinishCell"];
}

-(void)unlimitedUploadDataUploadSuccess {
	[self.tableView.mj_header beginRefreshing];
}


-(void)showFileWithModel:(MOUserTaskDataModel *)fileModel {
	
	if (fileModel.paste_board_url.length > 0) {
		MONavigationController *navVC = [MOWebViewController createWebViewAlertStyleWithTitle:fileModel.result.firstObject.file_name url:fileModel.paste_board_url ?:@""];
		MOWebViewController *webVC = navVC.viewControllers.firstObject;
		webVC.closeHandle = ^(MOWebViewController * _Nonnull webVC1) {
			[webVC1 dismissViewControllerAnimated:YES completion:NULL];
		};
		[self presentViewController:navVC animated:YES completion:NULL];
	}
}

-(CGFloat)getAudioCellHeight:(MOUserTaskDataModel *)model cacheByKey:(NSString *)cacheByKey{
    if (model.summarize_status == 0) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyVoiceScheduleCell" cacheByKey:cacheByKey configuration:^(MOMyVoiceScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeAudioInProcessCell" cacheByKey:cacheByKey configuration:^(MOSummarizeAudioInProcessCell * cell) {
            [cell configAudioCellWithDataModel:model];
        }];
        return height;
        
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeAudioFinishCell" cacheByKey:cacheByKey configuration:^(MOSummarizeAudioFinishCell * cell) {
        [cell configAudioCellWithDataModel:model];
    }];
    return height;
}

-(CGFloat)getPictureCellHeight:(MOUserTaskDataModel *)model cacheByKey:(NSString *)cacheByKey {
    
    if (model.summarize_status == 0) {
        
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyPictureScheduleCell" cacheByKey:cacheByKey configuration:^(MOMyPictureScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeImageVideoInProcessCell" cacheByKey:cacheByKey configuration:^(MOSummarizeImageVideoInProcessCell * cell) {
            [cell configImageCellWithDataModel:model];
        }];
        return height;
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeImageVideoFinishCell" cacheByKey:cacheByKey configuration:^(MOSummarizeImageVideoFinishCell * cell) {
        [cell configImageCellWithDataModel:model];
    }];
    return height;
}

-(CGFloat)getTextCellHeight:(MOUserTaskDataModel *)model cacheByKey:(NSString *)cacheByKey {
    
    if (model.summarize_status == 0) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyTextScheduleCell" cacheByKey:cacheByKey configuration:^(MOMyTextScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeTextInProcessCell" cacheByKey:cacheByKey configuration:^(MOSummarizeTextInProcessCell * cell) {
            [cell configFileCellWithDataModel:model];
        }];
        return height;
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeTextProcesFinishsCell" cacheByKey:cacheByKey configuration:^(MOSummarizeTextProcesFinishsCell * cell) {
        [cell configFileCellWithDataModel:model];
    }];
    return height;
}


-(CGFloat)getVideoCellHeight:(MOUserTaskDataModel *)model cacheByKey:(NSString *)cacheByKey {
    
    if (model.summarize_status == 0) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyVideoScheduleCell" cacheByKey:cacheByKey configuration:^(MOMyVideoScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeImageVideoInProcessCell" cacheByKey:cacheByKey configuration:^(MOSummarizeImageVideoInProcessCell * cell) {
            [cell configVideoCellWithDataModel:model];
        }];
        return height;
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeImageVideoFinishCell" cacheByKey:cacheByKey configuration:^(MOSummarizeImageVideoFinishCell * cell) {
        [cell configVideoCellWithDataModel:model];
    }];
    return height;
    
}


-(void)showImageSummarizeData:(MOUserTaskDataResultModel *)model {
    NSMutableArray *dataList = @[].mutableCopy;
    MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
    imageModel.type =  MOBrowseMediumItemTypeImage;
    imageModel.url = model.path;
    [dataList addObject:imageModel];
    MOBrowseMediumVC *vc = [[MOBrowseMediumVC alloc] initWithDataList:dataList selectedIndex:0];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:NULL];
}


-(void)showVideoSummarizeData:(MOUserTaskDataResultModel *)model {
    NSMutableArray *dataList = @[].mutableCopy;
    MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
    imageModel.type =  MOBrowseMediumItemTypeVideo;
    imageModel.url = model.path;
    [dataList addObject:imageModel];
    MOBrowseMediumVC *vc = [[MOBrowseMediumVC alloc] initWithDataList:dataList selectedIndex:0];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:NULL];
}


-(UITableViewCell *)getAudioCellWithIndex:(NSIndexPath *)indexPath {
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    if (model.summarize_status == 0 ) {
        MOMyVoiceScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOMyVoiceScheduleCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        [cell configCellData:model];
        cell.delegate = self;
        // 更新播放状态
        BOOL isPlaying = self.currentPlayingIndexPath && [self.currentPlayingIndexPath isEqual:indexPath];
        [cell updatePlayingState:isPlaying];
        
        WEAKSELF
        cell.didMsgBtnClick = ^{
			[weakSelf goMessageListWithDataId:model.model_id];

        };
        return cell;
    }
    
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        MOSummarizeAudioInProcessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeAudioInProcessCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        cell.delegate = self;
        [cell configAudioCellWithDataModel:model];
        BOOL isPlaying = self.currentPlayingIndexPath && [self.currentPlayingIndexPath isEqual:indexPath];
        [cell updatePlayingStateWithIsPlaying:isPlaying];
        
        return cell;
    }
    
    MOSummarizeAudioFinishCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeAudioFinishCell"];
    cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
    cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
    cell.delegate = self;
    [cell configAudioCellWithDataModel:model];
    BOOL isPlaying = self.currentPlayingIndexPath && [self.currentPlayingIndexPath isEqual:indexPath];
    [cell updatePlayingStateWithIsPlaying:isPlaying];
    WEAKSELF
    return cell;
}

-(UITableViewCell *)getPictrueCellWithIndex:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    
    
    if (model.summarize_status == 0) {
        
        MOMyPictureScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOMyPictureScheduleCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count -1;
        [cell configCellData:model];
        
        WEAKSELF
        cell.didPreviewClick = ^(NSInteger index){
            
            NSMutableArray *dataList = @[].mutableCopy;
            for (MOUserTaskDataResultModel *item in model.result) {
                MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
                imageModel.type = MOBrowseMediumItemTypeImage;
                imageModel.url = item.path;
                [dataList addObject:imageModel];
            }
            MOBrowseMediumVC *vc = [[MOBrowseMediumVC alloc] initWithDataList:dataList selectedIndex:index];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:vc animated:YES completion:NULL];
        };
        
        cell.didMsgBtnClick = ^{
			[weakSelf goMessageListWithDataId:model.model_id];
        };
        return cell;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        MOSummarizeImageVideoInProcessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeImageVideoInProcessCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count -1;
        [cell configImageCellWithDataModel:model];
        WEAKSELF
        cell.didPreviewClick = ^{
            [weakSelf showImageSummarizeData:model.result.firstObject];
        };
        return cell;
    }
    
    MOSummarizeImageVideoFinishCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeImageVideoFinishCell"];
    cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
    cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count -1;
    [cell configImageCellWithDataModel:model];
    WEAKSELF
    cell.didPreviewClick = ^{
        [weakSelf showImageSummarizeData:model.result.firstObject];
    };
    return cell;
    
}

-(UITableViewCell *)getTextCellWithIndex:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
	WEAKSELF
    if (model.summarize_status == 0) {
        MOMyTextScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOMyTextScheduleCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        [cell configCellData:model];
        
        cell.didMsgBtnClick = ^{
			[weakSelf goMessageListWithDataId:model.model_id];
        };
        return cell;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        
        MOSummarizeTextInProcessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeTextInProcessCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        [cell configFileCellWithDataModel:model];
		cell.didClickFile = ^(NSInteger index) {
			[weakSelf showFileWithModel:model];
		};
        return cell;
    }
    
    
    MOSummarizeTextProcesFinishsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeTextProcesFinishsCell"];
    cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
    cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
    [cell configFileCellWithDataModel:model];
	cell.didClickFile = ^(NSInteger index) {
		[weakSelf showFileWithModel:model];
	};
    return cell;
}

-(UITableViewCell *)getVideoCellWithIndex:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    if (model.summarize_status == 0) {
        
        MOMyVideoScheduleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOMyVideoScheduleCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count -1;
        MOUserTaskDataModel *model = self.dataList[indexPath.row];
        [cell configCellData:model];
        WEAKSELF
        cell.didPreviewClick = ^(NSInteger index){
            NSMutableArray *dataList = @[].mutableCopy;
            for (MOUserTaskDataResultModel *item in model.result) {
                MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
                imageModel.type =  item.cate == 4?MOBrowseMediumItemTypeVideo:MOBrowseMediumItemTypeImage;
                imageModel.url = item.path;
                [dataList addObject:imageModel];
            }
            MOBrowseMediumVC *vc = [[MOBrowseMediumVC alloc] initWithDataList:dataList selectedIndex:index];
            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:vc animated:YES completion:NULL];
        };
        cell.didMsgBtnClick = ^{
			[weakSelf goMessageListWithDataId:model.model_id];
        };
        return cell;
        
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        MOSummarizeImageVideoInProcessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeImageVideoInProcessCell"];
        [cell configVideoCellWithDataModel:model];
        WEAKSELF
        cell.didPreviewClick = ^{
            [weakSelf showVideoSummarizeData:model.result.firstObject];
        };
        return  cell;
    }
    
    MOSummarizeImageVideoFinishCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MOSummarizeImageVideoFinishCell"];
    [cell configVideoCellWithDataModel:model];
    WEAKSELF
    cell.didPreviewClick = ^{
        [weakSelf showVideoSummarizeData:model.result.firstObject];
    };
    return cell;
}


-(void)addTaskBtnClick {

	MOSelectUploadTypeVC *vc = [MOSelectUploadTypeVC new];
	vc.preferredContentSize = CGSizeMake(117, 168);
	vc.modalPresentationStyle = UIModalPresentationPopover;
	vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	vc.didSelectedIndex = ^(NSInteger index) {
		if (index == 0) {
			MORecordAudioNewVC *vc = [MORecordAudioNewVC createAlertStyle];
			[self presentViewController:vc animated:YES completion:NULL];
		}
		if (index == 1) {
			MOUploadPictureVC *vc = [MOUploadPictureVC createAlertStyle];
			[self presentViewController:vc animated:true completion:NULL];
		}
		if (index == 2) {
			MOUploadVideoVC *vc = [MOUploadVideoVC createAlertStyle];
			[self presentViewController:vc animated:true completion:NULL];
		}
		if (index == 3) {
			MOUploadTextFileVC *vc = [MOUploadTextFileVC createAlertStyle];
			[self presentViewController:vc animated:YES completion:NULL];
		}
	};
	
    UIPopoverPresentationController *popover = vc.popoverPresentationController;
    popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popover.sourceView = self.addTaskBtn;
	popover.sourceRect = CGRectMake(0, 0, self.addTaskBtn.bounds.size.width/2, self.addTaskBtn.bounds.size.height + 7);
    popover.delegate = (id<UIPopoverPresentationControllerDelegate>)self;
    popover.backgroundColor = [UIColor whiteColor];
	self.fd_interactivePopDisabled = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)goMessageListWithDataId:(NSInteger)dataId {
	
	MOMessageListVC *vc = [[MOMessageListVC alloc] initPresentationCustomStyleWithDataId:dataId dataCate:0 userTaskResultId:0];
	[self presentViewController:vc animated:YES completion:NULL];
}

#pragma mark UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
	
	return UIModalPresentationNone;
}
- (BOOL)presentationControllerShouldDismiss:(UIPresentationController *)presentationController {
	
	return YES;
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
	self.fd_interactivePopDisabled = NO;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld",(long)model.model_id];
    if (model.cate == 1) {
        return [self getAudioCellHeight:model cacheByKey:key];
    }
    
    if (model.cate == 2) {
        return [self getPictureCellHeight:model cacheByKey:key];
    }
    if (model.cate == 3) {
        return [self getTextCellHeight:model cacheByKey:key];
    }
    if (model.cate == 4) {
        return [self getVideoCellHeight:model cacheByKey:key];
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    if (model.cate == 1) {
        return  [self getAudioCellWithIndex:indexPath];
    }
    
    if (model.cate == 2) {
        return  [self getPictrueCellWithIndex:indexPath];
    }
    
    if (model.cate == 3) {
        return  [self getTextCellWithIndex:indexPath];
    }
    
    return [self getVideoCellWithIndex:indexPath];
    
}




#pragma mark - AudioPlayerCellDelegate

- (void)audioPlayerCellDidRequestPlay:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 如果当前已经有播放的Cell，且不是点击的这个Cell，停止它
    if (self.currentPlayingIndexPath && ![self.currentPlayingIndexPath isEqual:indexPath]) {
        MOMyVoiceScheduleCell *previousCell = [self.tableView cellForRowAtIndexPath:self.currentPlayingIndexPath];
        [previousCell stop];
    }
    
    // 更新当前播放的indexPath
    self.currentPlayingIndexPath = indexPath;
    
    // 开始播放
    MOMyVoiceScheduleCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [currentCell startPlaying];
    
    // 刷新表格以更新其他Cell的状态
    [self.tableView reloadData];
}

- (void)audioPlayerCell:(UITableViewCell *)cell didUpdateProgress:(float)progress currentTime:(NSTimeInterval)currentTime {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Cell %ld 播放进度: %.2f%%, 当前时间: %.2f", (long)indexPath.row, progress * 100, currentTime);
}

- (void)audioPlayerCell:(UITableViewCell *)cell didChangeState:(NSString *)state {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Cell %ld 状态变化: %@", (long)indexPath.row, state);
    if ([state isEqualToString:@"Finished"] || [state containsString:@"Error"]) {
        self.currentPlayingIndexPath = nil;
        [self.tableView reloadData];
    }
}




#pragma mark 懒加载
-(MOButton *)addTaskBtn {
	
	if (!_addTaskBtn) {
		_addTaskBtn = [MOButton new];
		[_addTaskBtn setImage:[UIImage imageNamedNoCache:@"icon_searchResult_add"]];
		[_addTaskBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
		[_addTaskBtn setEnlargeEdgeWithTop:5 left:5 bottom:5 right:5];
	}
	return  _addTaskBtn;
}

@end
