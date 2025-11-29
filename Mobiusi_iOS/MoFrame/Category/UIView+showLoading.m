//
//  UIView+showLoading.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/8.
//

#import "UIView+showLoading.h"
#import <SVProgressHUD/SVProgressHUD.h>
@implementation UIView (showLoading)
+(void)showLoading{
	
	[SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
	[SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
	[SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
	[SVProgressHUD setContainerView:self];
	[SVProgressHUD show];
}

+(void)hiddenLoading{
	
	[SVProgressHUD dismiss];
}
@end
