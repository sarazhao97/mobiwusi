//
//  MOBrowseMediumItemModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MOBrowseMediumItemTypeImage,
    MOBrowseMediumItemTypeVideo,
} MOBrowseMediumItemType;

@interface MOBrowseMediumItemModel : MOModel
@property(nonatomic,strong,nullable)UIImage *image;
@property(nonatomic,assign)MOBrowseMediumItemType type;
@property(nonatomic,copy,nullable)NSString *url;
@end

NS_ASSUME_NONNULL_END
