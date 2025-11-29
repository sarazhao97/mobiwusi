//
//  MOUserTaskDataModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/27.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MOUserTaskDataResultModel;
@class MOUserTaskDataAnnotationInfoModel;
@interface MOUserTaskDataModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,copy)NSString *task_title;
@property(nonatomic,copy)NSString *upload_time;
@property(nonatomic,copy)NSString *task_no;
//数据类型 0全部 1音频 2图片 3:文件 4：视频
@property(nonatomic,assign)NSInteger cate;
//topic_type 1：试做数据 2：正式数据
@property(nonatomic,assign)NSInteger topic_type;
@property(nonatomic,strong)NSMutableArray<MOUserTaskDataResultModel *> *result;
@property(nonatomic,strong)NSMutableArray<MOUserTaskDataAnnotationInfoModel *> *annotationInfo;
@property(nonatomic,assign)BOOL is_not_read;
//0 非总结类型  1：待总结 2：成功 3：失败
@property(nonatomic,assign)NSInteger summarize_status;
@property(nonatomic,copy,nullable)NSString * paste_board_url;
@property(nonatomic,copy,nullable)NSString * idea;
@property(nonatomic,copy,nullable)NSString * location;

@end


@interface MOUserTaskDataResultModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,copy)NSString *path;
@property(nonatomic,copy)NSString *file_name;
@property(nonatomic,copy)NSString *data_param;
@property(nonatomic,copy)NSString * snapshot;
@property(nonatomic,assign)NSInteger cate;
@property(nonatomic,assign)NSInteger duration;
@property(nonatomic,copy)NSString * preview_url;
//本地自定义属性
@property(nonatomic,strong)UIImage *thumbnailImage;

@end

@interface MOUserTaskDataAnnotationInfoModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,copy)NSString *user_id;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,assign)NSInteger cate;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic,copy)NSString *cate_name;
@end

NS_ASSUME_NONNULL_END
