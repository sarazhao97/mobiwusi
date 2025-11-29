//
//  MOCateOptionModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MOCateOptionItem;
@interface MOCateOptionModel : MOModel
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *audio_cate;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *cert_type;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *complaint_type;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *feedback_type;
@property(nonatomic,copy)NSString *general_image;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *image_cate;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *task_type;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *text_cate;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *user_file_type;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *video_cate;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *withdrawal_money;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *work_type;
@property(nonatomic,strong)NSMutableArray<MOCateOptionItem *> *work_income;
@end


@interface MOCateOptionItem : MOModel
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *value;
@end
NS_ASSUME_NONNULL_END
