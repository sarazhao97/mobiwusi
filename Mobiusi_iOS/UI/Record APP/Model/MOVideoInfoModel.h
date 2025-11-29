//
//  MOVideoInfoModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOVideoInfoModel : MOModel
@property(nonatomic,strong)NSData *data;
@property(nonatomic,strong)UIImage *thumbnail;
@property(nonatomic,strong)NSURL *mediaURL;
@end

NS_ASSUME_NONNULL_END
