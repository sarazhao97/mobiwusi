//
//  MOTaskDetailModel.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/21.
//

#import "MOModel.h"

@class MOTaskDetailTag;

@class MOTaskDetailDescribe;

NS_ASSUME_NONNULL_BEGIN

@interface MOTaskDetailModel : MOModel
//任务编号
@property (nonatomic, assign) NSInteger task_id;
//是否关注
@property (nonatomic, assign) NSInteger is_follow;
/// 是否可以领取任务 1：是； 0：否
@property (nonatomic, assign) NSInteger is_get;
@property (nonatomic, assign) NSInteger completed_topic_num;
//任务题目
@property (nonatomic, copy) NSString *title;
//任务编号
@property (nonatomic, copy) NSString *task_no;
//单位
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, assign) NSInteger user_id;
//用户任务 id
@property (nonatomic, assign) NSInteger user_task_id;
//价格
@property (nonatomic, copy) NSString *price;
//题目说明
@property (nonatomic, copy) NSString *data_detail;
@property (nonatomic, copy) NSString *publish;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *user_avatar;
@property (nonatomic, copy) NSString *task_ask;
@property (nonatomic, copy) NSString *receiving_orders_desc;
//类型
@property (nonatomic, assign) NSInteger cate;
//@property (nonatomic, copy) NSArray<MOTaskDetailTag *> *tags; // 可以考虑定义一个 Tag 类
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, copy) NSArray<MOTaskDetailDescribe *> *task_describe; // 可以考虑定义一个 Describe 类

//新加
//是否是试做
@property (nonatomic, assign) BOOL is_try;
///测试状态
@property (nonatomic, assign) NSInteger try_status;
//试做题目数量
@property (nonatomic, assign) NSInteger try_topic_num;
//试做完成题目
@property (nonatomic, assign) NSInteger try_finished;
//是否需要输入文本
@property (nonatomic, assign) BOOL is_need_describe;

//文本文件后缀
@property (nonatomic, copy) NSString* file_type;

//试做完成题目
@property (nonatomic, assign) NSInteger finished;
//题目总数
@property (nonatomic, assign) NSInteger topic_total;
//样例
@property (nonatomic, copy) NSString *example_url;
//任务要求
@property (nonatomic, copy) NSString *recording_requirements;
//图片数量限制
@property (nonatomic, assign) NSInteger limit_of_one_upload_image;
//视频数量限制
@property (nonatomic, assign) NSInteger limit_of_one_upload_video;
//文件数量限制
@property (nonatomic, assign) NSInteger limit_of_one_upload_file;
//文本 | 人数限制: 100 人
@property (nonatomic, copy) NSString *task_details_param;
//用户任务状态：1:进行中 2：待审核；3：未通过 4：初审通过 5 已通过
@property (nonatomic, assign) NSInteger task_status;
@property (nonatomic, assign) BOOL is_plain_text;
@end

@interface MOTaskDetailTag : NSObject

@property (nonatomic, assign) NSInteger enable;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger tag_id;
@property (nonatomic, copy) NSString *sub_type;
@property (nonatomic, copy) NSString *sbu_type_value;

@end

@interface MOTaskDetailDescribe : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *val;

@end

NS_ASSUME_NONNULL_END
