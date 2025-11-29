//
//  MOMyTextDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOMyTextDataVC.h"
#import "MOMessageListVC.h"
#import "Mobiusi_iOS-Swift.h"

@interface MOMyTextDataVC ()
@end

@implementation MOMyTextDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBar.titleLabel.text = NSLocalizedString(@"我的文本",nil);
    [self.tableView registerClass:[MOMyTextScheduleCell class] forCellReuseIdentifier:@"MOMyTextScheduleCell"];
    [self.tableView registerClass:[MOSummarizeTextInProcessCell class] forCellReuseIdentifier:@"MOSummarizeTextInProcessCell"];
    [self.tableView registerClass:[MOSummarizeTextProcesFinishsCell class] forCellReuseIdentifier:@"MOSummarizeTextProcesFinishsCell"];
}


-(void)showFileWithModel:(MOUserTaskDataModel *)fileModel {
	
	if (fileModel.paste_board_url.length > 0) {
		MONavigationController *navVC = [MOWebViewController createWebViewAlertStyleWithTitle:fileModel.result.firstObject.file_name url:fileModel.paste_board_url];
		MOWebViewController *webVC = navVC.viewControllers.firstObject;
		webVC.closeHandle = ^(MOWebViewController * _Nonnull webVC1) {
			[webVC1 dismissViewControllerAnimated:YES completion:NULL];
		};
		[self presentViewController:navVC animated:YES completion:NULL];
	}
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld",model.model_id];
    if (model.summarize_status == 0) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyTextScheduleCell" cacheByKey:key configuration:^(MOMyTextScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeTextInProcessCell" cacheByKey:key configuration:^(MOSummarizeTextInProcessCell * cell) {
            [cell configFileCellWithDataModel:model];
        }];
        return height;
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeTextProcesFinishsCell" cacheByKey:key configuration:^(MOSummarizeTextProcesFinishsCell * cell) {
        [cell configFileCellWithDataModel:model];
    }];
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    MOUserTaskDataModel *model = self.dataList[indexPath.row];
	WEAKSELF
    if (model.summarize_status == 0) {
        MOMyTextScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOMyTextScheduleCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        [cell configCellData:model];
        cell.didMsgBtnClick = ^{
            MOMessageListVC *vc = [[MOMessageListVC alloc] initPresentationCustomStyleWithDataId:model.model_id dataCate:0 userTaskResultId:0];
            [weakSelf presentViewController:vc animated:YES completion:NULL];
        };
		cell.didClickFile = ^(NSInteger index) {
			[weakSelf showFileWithModel:model];
		};
        return cell;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        
        MOSummarizeTextInProcessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOSummarizeTextInProcessCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
        [cell configFileCellWithDataModel:model];
		cell.didClickFile = ^(NSInteger index) {
			[weakSelf showFileWithModel:model];
		};
        return cell;
    }
    
    
    MOSummarizeTextProcesFinishsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOSummarizeTextProcesFinishsCell"];
    cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
    cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count - 1;
    [cell configFileCellWithDataModel:model];
    

	cell.didClickFile = ^(NSInteger index) {
		[weakSelf showFileWithModel:model];
	};
    return cell;
}


@end
