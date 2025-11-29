//
//  MONotificationCustomDataModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/7.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MONotificationAlertModel;
@class MONotificationAPSModel;
@class MONotificationCustomDataModel;


@interface MONotificationUserInfoModel : MOModel
@property(nonatomic,strong)MONotificationAPSModel *aps;
@property(nonatomic,strong)NSString *custom;
@property(nonatomic,copy)NSString *d;
@property(nonatomic,assign)NSInteger p;
@end

@interface MONotificationAPSModel : MOModel
@property(nonatomic,strong)MONotificationAlertModel *alert;
@property(nonatomic,copy)NSString *sound;
@end

@interface MONotificationAlertModel : MOModel
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subtitle;
@property(nonatomic,copy)NSString *body;
@end

@interface MONotificationBodyModel : MOModel
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subtitle;
@property(nonatomic,copy)NSString *body;
@end

@interface MONotificationCustomDataModel : MOModel
@property(nonatomic,copy)NSString *relate_table;
//relate_id 等同于 task_id 任务ID
@property(nonatomic,assign)NSInteger relate_id;
@property(nonatomic,assign)NSInteger task_id;
//1音频 2图片 3:文件 4：视频
//9: 用户数据总结[废弃]relate table:user task result
//10:加工数据; relate table: annotation order
//11:用户数据总结 relate table: user paste board content
@property(nonatomic,assign)NSInteger type_id;
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,assign)BOOL is_dialog;
@end

NS_ASSUME_NONNULL_END
