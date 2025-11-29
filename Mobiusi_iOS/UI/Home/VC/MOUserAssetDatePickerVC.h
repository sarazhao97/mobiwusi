//
//  MOUserAssetDatePickerVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOUserAssetDatePickerVC : MOBaseViewController
@property(nonatomic,copy)void(^didConfirmButtonClick)(NSString *simpleDateStr,NSString *chinaDateStr,NSDate *date);
-(void)showAnimate;
@end

NS_ASSUME_NONNULL_END
