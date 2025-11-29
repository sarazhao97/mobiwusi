//
//  MOBaseMyDataVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/27.
//

#import "MOBaseViewController.h"
#import "MONavBarView.h"
#import "MOMyTextScheduleCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "MOUserTaskDataModel.h"
#import "MOAlmostFullScreenMaskPC.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOBaseMyDataVC : MOBaseViewController
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) BOOL user_paste_board;

@property (nonatomic, assign) NSInteger task_status;
@property(nonatomic,strong)MONavBarView *navBar;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray<MOUserTaskDataModel *> *dataList;
@property(nonatomic,assign)NSInteger cate;
@property(nonatomic,assign)NSInteger userTaskId;
@property (nonatomic, strong) MOAlmostFullScreenMasDelegate *myTransitionDelegate;

+ (MONavigationController *)creatPresentationCustomStyleWithNavigationRootVCWithCate:(NSInteger)cate userTaskId:(NSInteger)userTaskId;
- (instancetype)initPresentationCustomStyleWithCate:(NSInteger)cate userTaskId:(NSInteger)userTaskId;
- (instancetype)initWithCate:(NSInteger)cate userTaskId:(NSInteger)userTaskId user_paste_board:(BOOL)user_paste_board;
-(void)goSummarizeVCWithModel:(MOUserTaskDataModel*)model;
@end

NS_ASSUME_NONNULL_END
