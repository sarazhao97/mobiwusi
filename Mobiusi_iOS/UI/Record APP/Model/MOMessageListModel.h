//
//  MOMessageListModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOModel.h"
NS_ASSUME_NONNULL_BEGIN
@class MOMessageListItemModel;
@interface MOMessageListModel : MOModel
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,assign)NSInteger page_total;
@property(nonatomic,assign)NSInteger total;
@property(nonatomic,assign)NSInteger limit;
@property(nonatomic,strong)NSMutableArray<MOMessageListItemModel *>* list;
@end

@interface MOMessageListItemModel : MOModel
@property(nonatomic,copy)NSString* content;
@property(nonatomic,assign)NSInteger type_id;
@property(nonatomic,copy)NSString* type_name;
@property(nonatomic,copy)NSString* title;
@property(nonatomic,copy)NSString* image;
@property(nonatomic,copy)NSString* create_time;
@property(nonatomic,strong)NSMutableArray* content_images;
@property(nonatomic,copy)NSString* icon;


//type_id == 2 的时候 relate_id 用户任务ID
@property(nonatomic,assign)NSInteger relate_id;
@property(nonatomic,assign)NSInteger task_id;
@end

@interface MOSummarizeMessageItemModel : MOMessageListItemModel
@property(nonatomic,assign)NSInteger user_id;
@property(nonatomic,assign)NSInteger user_paste_board_id;
@property(nonatomic,assign)NSInteger operation_type;
@property(nonatomic,assign)NSInteger operation_status;
@property(nonatomic,copy)NSString* user_name;
@property(nonatomic,copy,nullable)NSString* user_avatar;
@property(nonatomic,copy)NSString* operation_type_text;
@property(nonatomic,copy)NSString* operation_content;
@end

NS_ASSUME_NONNULL_END
