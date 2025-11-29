//
//  UIButton+CountDown.h
//  TKFamilyTrust
//
//  Created by zhangxiaoliang01 on 2021/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (CountDown)
-(void)startCountDownWithTitle:(NSString *(^)(UIButton *btn,NSInteger count))intervalCallBack;
-(void)stopCountDown;
@end

NS_ASSUME_NONNULL_END
