//
//  MOBaseRequestModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOBaseRequestModel : MOModel
@property(nonatomic,copy,nullable)NSString *hostRelativeUrl;
@property(nonatomic,strong,nullable)Class responseClass;
-(void)startRequestWithComplete:(void(^)(NSString * _Nullable errorMsg,id _Nullable responseModel))complete;
@end

NS_ASSUME_NONNULL_END
