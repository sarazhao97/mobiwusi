//
//  MOMyAudioDataVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/3.
//

#import "MOMyAudioDataVC.h"
#import "MOMessageListVC.h"
#import "MOMyVoiceScheduleCell.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOMyAudioDataVC ()<MOMyVoiceScheduleCellDelegate>

@property (nonatomic, strong) NSIndexPath *currentPlayingIndexPath; // 当前播放的Cell的indexPath

@end

@implementation MOMyAudioDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBar.titleLabel.text = NSLocalizedString(@"我的音频", nil);
    [self.tableView registerClass:[MOMyVoiceScheduleCell class] forCellReuseIdentifier:@"MOMyVoiceScheduleCell"];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    if (model.summarize_status == 0) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyVoiceScheduleCell" cacheByKey:key configuration:^(MOMyVoiceScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeAudioInProcessCell" cacheByKey:key configuration:^(MOSummarizeAudioInProcessCell * cell) {
            [cell configAudioCellWithDataModel:model];
        }];
        return height;
        
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeAudioFinishCell" cacheByKey:key configuration:^(MOSummarizeAudioFinishCell * cell) {
        [cell configAudioCellWithDataModel:model];
    }];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    if (model.summarize_status == 0 ) {
        MOMyVoiceScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOMyVoiceScheduleCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        [cell configCellData:model];
        cell.delegate = self;
        // 更新播放状态
        BOOL isPlaying = self.currentPlayingIndexPath && [self.currentPlayingIndexPath isEqual:indexPath];
        [cell updatePlayingState:isPlaying];
        
        WEAKSELF
        cell.didMsgBtnClick = ^{
            MOMessageListVC *vc = [[MOMessageListVC alloc] initPresentationCustomStyleWithDataId:model.model_id dataCate:0 userTaskResultId:0];
            [weakSelf presentViewController:vc animated:YES completion:NULL];
        };
        return cell;
    }
    
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        MOSummarizeAudioInProcessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOSummarizeAudioInProcessCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        cell.delegate = self;
        [cell configAudioCellWithDataModel:model];
        BOOL isPlaying = self.currentPlayingIndexPath && [self.currentPlayingIndexPath isEqual:indexPath];
        [cell updatePlayingStateWithIsPlaying:isPlaying];
        
        return cell;
    }
    
    MOSummarizeAudioFinishCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOSummarizeAudioFinishCell"];
    cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
    cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
    cell.delegate = self;
    [cell configAudioCellWithDataModel:model];
    BOOL isPlaying = self.currentPlayingIndexPath && [self.currentPlayingIndexPath isEqual:indexPath];
    [cell updatePlayingStateWithIsPlaying:isPlaying];
    WEAKSELF
    return cell;
    
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

@end
