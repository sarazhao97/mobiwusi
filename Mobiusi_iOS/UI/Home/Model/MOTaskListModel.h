//
//  MOTaskListModel.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/13.
//

#import "MOModel.h"
@class MOTaskListTagModel;
@class MOTaskDescModel;


NS_ASSUME_NONNULL_BEGIN

@interface MOTaskListModel : MOModel
//我的任务界面，接口参数 task_id 就是user_task_id
@property (nonatomic, assign) NSInteger task_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *task_no;
@property (nonatomic, assign) NSInteger user_id;
///题目数量
@property (nonatomic, assign) NSInteger topic_num;
@property (nonatomic, copy,nullable) NSString *unit;
@property (nonatomic, copy,nullable) NSString *currency_unit;
@property (nonatomic, copy,nullable) NSString *price;
@property (nonatomic, copy) NSString *data_detail;
@property (nonatomic, copy) NSString *publish;
//@property (nonatomic, copy) NSArray<MOTaskListTagModel *> *tags;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *user_avatar;
@property (nonatomic, copy) NSString *task_ask;
@property (nonatomic, copy) NSString *receiving_orders_desc;
/// 任务要求（弹窗用）
@property (nonatomic, copy) NSString *recording_requirements;
///1：已关注 0：未关注
@property (nonatomic, assign) NSInteger is_follow;
///用户任务审核状态：1:进行中 2:待审核 3:未通过 4:初审通过 5：已完成
@property (nonatomic, strong) NSNumber *task_status;
///0全部 1音频 2图片 3:文件 4：视频
@property (nonatomic, assign) NSInteger cate;
///是否允许领取任务 1：允许领取 0：不能领取
@property (nonatomic, assign) NSInteger is_get;
///多少人录制
@property (nonatomic, assign) NSInteger user_task_num;
//从我的任务界面进入时，没有该字段
@property (nonatomic, assign) NSInteger user_task_id;

@property (nonatomic, copy) NSString *simple_descri;
///允许的文件类型
@property (nonatomic, copy) NSString *file_type;

@property (nonatomic, copy) NSArray<MOTaskDescModel *> *task_describe;
///样例URL
@property (nonatomic, copy) NSString *example_url;
///是否需要文本
@property (nonatomic, assign) NSInteger is_need_describe;
///单次允许上传的图片限制
@property (nonatomic, assign) NSInteger limit_of_one_upload_image;
///单次允许上传的图片限制
@property (nonatomic, assign) NSInteger limit_of_one_upload_video;
///单次允许上传的文件限制
@property (nonatomic, assign) NSInteger limit_of_one_upload_file;
///1:需要试做 0：不需要
@property (nonatomic, assign) NSInteger is_try;
///1:试做通过 2：驳回 3: 审核中
@property (nonatomic, assign) NSInteger try_status;
/// 领取时间
@property (nonatomic, copy) NSString * receive_time;

@property (nonatomic, assign) BOOL is_plain_text;

//试做题目数量
@property (nonatomic, assign) NSInteger try_topic_num;
//试做完成题目
@property (nonatomic, assign) NSInteger try_finished;

//试做完成题目
@property (nonatomic, assign) NSInteger finished;

//自定义计算属性
@property(nonatomic,assign,readonly)NSInteger topic_type;
//剩多少名额
@property (nonatomic, assign) NSInteger remaining_places;
@property (nonatomic, assign) NSInteger person_limit;
//1:采集项目 2：加工项目
@property (nonatomic, assign) NSInteger task_type;
@end

@interface MOTaskListTagModel : MOModel
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger enable;
@end

@interface MOTaskDescModel : MOModel
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *val;

@end

@interface MOMyTaskListModel : MOTaskListModel
@end

@interface MOTaskDetailNewModel : MOTaskListModel

//新加

//文本 | 人数限制: 100 人
@property (nonatomic, copy) NSString *task_details_param;
@property (nonatomic, copy) NSString *currency_unit;
//0：未支付； 1:已支付
@property (nonatomic, assign)NSInteger is_pay;

//用户任务状态：1:进行中 2：待审核；3：未通过 4：初审通过 5 已通过

@end

NS_ASSUME_NONNULL_END
