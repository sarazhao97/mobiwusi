//
//  MOSearchResultModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MOSearchResultCateModel;

@interface MOSearchResultModel : MOModel
@property(nonatomic,strong)NSMutableArray<MOSearchResultCateModel *> *audio_list;
@property(nonatomic,strong)NSMutableArray<MOSearchResultCateModel *> *image_list;
@property(nonatomic,strong)NSMutableArray<MOSearchResultCateModel *> *text_list;
@property(nonatomic,strong)NSMutableArray<MOSearchResultCateModel *> *video_list;
@end


@interface MOSearchResultCateModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,assign)NSInteger cate;
@property(nonatomic,copy)NSString* data_detail;
@property(nonatomic,copy)NSString* file_type;
@property(nonatomic,assign)BOOL is_follow;
@property(nonatomic,assign)BOOL is_get;
@property(nonatomic,assign)BOOL is_need_describe;
@property(nonatomic,assign)BOOL is_plain_text;
@property(nonatomic,assign)BOOL is_try;
@property(nonatomic,assign)NSInteger limit_of_one_upload_file;
@property(nonatomic,assign)NSInteger limit_of_one_upload_image;
@property(nonatomic,assign)NSInteger limit_of_one_upload_video;
@property(nonatomic,copy)NSString* price;
@property(nonatomic,copy)NSString* publish;
@property(nonatomic,assign)NSInteger receive_times;
@property(nonatomic,copy)NSString* recording_requirements;
@property(nonatomic,copy)NSString* simple_descri;
@property(nonatomic,copy)NSString* task_no;
@property(nonatomic,assign)NSInteger task_status;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,assign)NSInteger topic_num;
@property(nonatomic,assign)NSInteger try_status;
@property(nonatomic,assign)NSInteger try_topic_num;
@property(nonatomic,copy)NSString* unit;
@property(nonatomic,copy)NSString* user_id;
@property(nonatomic,assign)NSInteger user_receive_times;
@property(nonatomic,assign)NSInteger user_task_id;
@property(nonatomic,assign)NSInteger user_task_num;
@end

@interface MOSearchResultSetcionModel : MOModel
@property(nonatomic,copy)NSString *title;
@property(nonatomic,assign)NSInteger cate;
@property(nonatomic,strong)NSMutableArray<MOSearchResultCateModel *>* setcionDataList;
@end
NS_ASSUME_NONNULL_END
