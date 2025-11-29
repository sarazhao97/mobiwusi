//
//  MOMsgAlertView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/4.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOMsgAlertView : MOView


+ (void)showWithTitle:(NSString *)title andMsg:(NSString *)msg andSureClickHandle:(MOBlock)sure;

+ (void)showWithTitle:(NSString *)title andMsg:(NSString *)msg cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle andSureClickHandle:(MOBlock)sure;


@end

NS_ASSUME_NONNULL_END
