//
//  MOMyPictureDataVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOMyPictureDataVC.h"
#import "MONavBarView.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "MOMyPictureScheduleCell.h"
#import "MOBrowseMediumVC.h"
#import "MOMessageListVC.h"
#import "Mobiusi_iOS-Swift.h"


@interface MOMyPictureDataVC ()

@end

@implementation MOMyPictureDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[MOMyPictureScheduleCell class] forCellReuseIdentifier:@"MOMyPictureScheduleCell"];
    [self.tableView registerClass:[MOSummarizeImageVideoInProcessCell class] forCellReuseIdentifier:@"MOSummarizeImageVideoInProcessCell"];
    [self.tableView registerClass:[MOSummarizeImageVideoFinishCell class] forCellReuseIdentifier:@"MOSummarizeImageVideoFinishCell"];
    self.navBar.titleLabel.text = NSLocalizedString(@"我的图片", nil);

    
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

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    NSString *key = [NSString stringWithFormat:@"%ld",(long)model.model_id];
    
    if (model.summarize_status == 0) {
        
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOMyPictureScheduleCell" cacheByKey:key configuration:^(MOMyPictureScheduleCell * cell) {
            [cell configCellData:model];
        }];
        return height;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeImageVideoInProcessCell" cacheByKey:key configuration:^(MOSummarizeImageVideoInProcessCell * cell) {
            [cell configImageCellWithDataModel:model];
        }];
        return height;
    }
    
    CGFloat height =  [self.tableView fd_heightForCellWithIdentifier:@"MOSummarizeImageVideoFinishCell" cacheByKey:key configuration:^(MOSummarizeImageVideoFinishCell * cell) {
        [cell configImageCellWithDataModel:model];
    }];
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
    MOUserTaskDataModel *model = self.dataList[indexPath.row];
    
    
    if (model.summarize_status == 0) {
        
        MOMyPictureScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOMyPictureScheduleCell"];
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
            MOMessageListVC *vc = [[MOMessageListVC alloc] initPresentationCustomStyleWithDataId:model.model_id dataCate:0 userTaskResultId:0];
            [weakSelf presentViewController:vc animated:YES completion:NULL];
        };
        return cell;
    }
    
    if (model.summarize_status == 1 || model.summarize_status == 3) {
        MOSummarizeImageVideoInProcessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOSummarizeImageVideoInProcessCell"];
        cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
        cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count -1;
        [cell configImageCellWithDataModel:model];
        WEAKSELF
        cell.didPreviewClick = ^{
            [weakSelf showImageSummarizeData:model.result.firstObject];
        };
        return cell;
    }
    
    MOSummarizeImageVideoFinishCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOSummarizeImageVideoFinishCell"];
    cell.scheduleVerticalTopView.hidden = indexPath.row == 0;
    cell.scheduleVerticalBottomView.hidden = indexPath.row == self.dataList.count -1;
    [cell configImageCellWithDataModel:model];
    WEAKSELF
    cell.didPreviewClick = ^{
        [weakSelf showImageSummarizeData:model.result.firstObject];
    };
    
    return cell;
}


@end
