//
//  MOMessageListVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOBaseViewController.h"
#import "MOAlmostFullScreenMaskPC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOMessageListVC : MOBaseViewController
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger limit;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)BOOL isPresented;
@property (nonatomic, strong) MOAlmostFullScreenMasDelegate *myTransitionDelegate;
- (instancetype)initWithDataId:(NSInteger)dataId dataCate:(NSInteger)data_cate userTaskResultId:(NSInteger)userTaskResultId;
- (instancetype)initPresentationCustomStyleWithDataId:(NSInteger)dataId
											 dataCate:(NSInteger)data_cate
									 userTaskResultId:(NSInteger)userTaskResultId;
-(void)showCloseBtn;
-(void)hiddenBackBtn;
-(void)loadRequest;
@end

NS_ASSUME_NONNULL_END
