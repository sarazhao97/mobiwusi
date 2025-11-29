//
//  MOLoginBottomView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    LoginTypeWX,
    LoginTypeAliPay,
    LoginTypeAppleId,
} MOLoginType;

@interface MOLoginBottomView : MOView
@property(nonatomic,strong)MOButton *wxLoginBtn;
@property(nonatomic,strong)MOButton *aliPayLoginBtn;
@property(nonatomic,strong)MOButton *appleIdLoginBtn;
@property(nonatomic,copy)void(^loginBtnClick)(MOLoginType loginType);
@end

NS_ASSUME_NONNULL_END
