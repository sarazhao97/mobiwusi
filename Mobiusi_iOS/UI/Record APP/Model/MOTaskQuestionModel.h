//
//  MOTaskQuestionModel.h
//  Mobiusi_iOS
//
//  Created by x11 on 2025/2/24.
//

#import "MOModel.h"
@class MOTaskQuestionDataModel;
@class  MOTaskQuestionModelProperty;
NS_ASSUME_NONNULL_BEGIN

@interface MOTaskQuestionModel : MOModel
@property (nonatomic, assign) NSInteger model_id;               // 任务ID
///1:待审核 2：通过 3：拒绝
@property (nonatomic, assign) NSInteger status;           // 状态
@property (nonatomic, copy) NSString *text;               // 任务文本
@property (nonatomic, copy) NSString *result;                  // 结果
@property (nonatomic, assign) NSInteger duration;         // 持续时间
@property (nonatomic, assign) NSInteger index;            // 索引

@property (nonatomic, copy) NSString *demand;             // 要求
@property (nonatomic, copy) NSString *ex_url;             // 示例链接
@property (nonatomic, copy) NSString *remark;             // 错误备注
@property (nonatomic, copy) NSString *text_data;             // 备注
@property (nonatomic, copy) NSString *task_title;             // 任务标题
@property (nonatomic, strong) NSArray<MOTaskQuestionDataModel *> *file_data;
@property (nonatomic, strong) NSArray<MOTaskQuestionDataModel *> *audio_data;
@property (nonatomic, strong) NSArray<MOTaskQuestionDataModel *> *video_data;
@property (nonatomic, strong) NSArray<MOTaskQuestionDataModel *> *picture_data;

@end


@interface MOTaskQuestionModelProperty : NSObject
@property (nonatomic, copy,nullable) NSString *name;
@property (nonatomic, copy,nullable) NSString *value;
@end


@interface MOTaskQuestionDataModel : NSObject
@property (nonatomic, assign) NSInteger model_id;
@property (nonatomic, strong,nullable) NSString *url;
// 1音频 2图片 3:文件 4：视频
@property (nonatomic, assign) NSInteger cate;
@property (nonatomic, strong) NSString *caption;
//0进行中 1:待审核 2：通过 3：拒绝
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString* file_name;
@property (nonatomic, copy) NSString* snapshot;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, copy) NSString* remark;
@property (nonatomic, copy,nullable) NSString* data_param;
@property (nonatomic, copy) NSString* status_zh;
@property (nonatomic, strong) NSMutableArray<MOTaskQuestionModelProperty *>* property;
@end

NS_ASSUME_NONNULL_END
