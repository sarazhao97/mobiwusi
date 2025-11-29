//
//  UIDevice+Info.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (Info)

+(CGFloat)statusBarFromCode;
+(NSString *)getCarrierName;
+(void)getCarrierInfo;
@end

NS_ASSUME_NONNULL_END
