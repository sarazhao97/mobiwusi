//
//  MOTaskProcessView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/28.
//

#import "MOView.h"
#import "MOTaskListModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TaskStateNotStarted,
    TaskStateInProgress,
    TaskStateCompletedTestData,
    TaskStateInReview,
    TaskStateFail,
    TaskStateApproved,
} TaskState;

@interface MOTaskProcessView : MOView
@property(nonatomic,strong)MOView *markView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOView *processView;
-(void)configViewWithModel:(MOTaskDetailNewModel *)model;
@end

@interface MOProcessView : MOView
+(instancetype)createNormal;
+(instancetype)createFail;
+(instancetype)createSuccess;
+(instancetype)createInReview;
+(instancetype)createInProcess;

-(void)showNormal;
-(void)showFail;
-(void)showSuccess;
@end
NS_ASSUME_NONNULL_END
