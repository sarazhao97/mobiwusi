//
//  MOCountryCodeModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOCountryCodeModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,copy)NSString*name;
@property(nonatomic,assign)NSInteger value;
@property(nonatomic,copy)NSString* pinyin;

@end

NS_ASSUME_NONNULL_END
