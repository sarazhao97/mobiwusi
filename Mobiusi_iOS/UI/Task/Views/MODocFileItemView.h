//
//  MODocFileItemView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MODocFileItemView : MOView
@property(nonatomic,copy)void(^didCilck)(void);
@property(nonatomic,strong)UIImageView *fileIconImageView;
@property(nonatomic,strong)UILabel *fileNameLabel;
@end

NS_ASSUME_NONNULL_END
