//
//  MOMyTagTypeModel.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/10/5.
//

#import "MOModel.h"
@class MOMyTagModel;

NS_ASSUME_NONNULL_BEGIN

@interface MOMyTagTypeModel : MOModel
@property (nonatomic, copy) NSString *name;                // "身份数据"
@property (nonatomic, assign) NSInteger value;              // 1
@property (nonatomic, assign) NSInteger relate_value;       // 0
@property (nonatomic, copy) NSString *icon_url;             // "http://m.mobi.yu-yun.com/static/app/image/user_tag_type1.png"
@property (nonatomic, copy) NSString *add_value;            // "#E0A15D,#FFEFE0"
@property (nonatomic, copy) NSString *cate_alias;           // ""
@property (nonatomic, copy) NSString *font_color;           // "#E0A15D"
@property (nonatomic, copy) NSString *bg_color;             // "#FFEFE0"
@property (nonatomic, copy) NSArray<MOMyTagModel *> *tags;

@end

@interface MOMyTagModel : MOModel
@property (nonatomic, assign) NSInteger model_id;                 // 1
@property (nonatomic, copy) NSString *name;                 // "90后"
@property (nonatomic, copy) NSString *remark;               // ""
@property (nonatomic, assign) NSInteger is_auth;            // 1
@property (nonatomic, copy) NSString *font_color;           // "#6AC17A"
@property (nonatomic, copy) NSString *bg_color;
@property (nonatomic, assign) NSInteger value;            // 1
@property (nonatomic, assign) NSInteger relate_value;            // 1

@end


NS_ASSUME_NONNULL_END
