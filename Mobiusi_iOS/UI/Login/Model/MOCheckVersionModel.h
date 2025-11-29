//
//  MOCheckVersionModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/17.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOCheckVersionModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,copy)NSString* ver_name;
@property(nonatomic,assign)NSInteger ver_code;
@property(nonatomic,assign)BOOL is_force;
@property(nonatomic,copy)NSString* download_url;
@property(nonatomic,copy)NSString* ver_describe;
@property(nonatomic,copy)NSString* begin_time;
@property(nonatomic,assign)BOOL enabled;
@property(nonatomic,copy)NSString* app_name;
@property(nonatomic,assign)NSInteger is_index_tips;
@property(nonatomic,assign)NSInteger app_type;
@end

NS_ASSUME_NONNULL_END
