//
//  MOInputAlertView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/4.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOInputAlertView : MOView

+ (void)showWithTitle:(NSString *)title andMsg:(NSString *)msg andPlaceHolder:(NSString *)placeHolder andMaxCount:(NSInteger)maxCount andSureClickHandle:(MOStringBlock)sure;

@end

NS_ASSUME_NONNULL_END
