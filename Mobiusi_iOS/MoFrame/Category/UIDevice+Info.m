//
//  UIDevice+Info.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/6.
//

#import "UIDevice+Info.h"

@implementation UIDevice (Info)

+(CGFloat)statusBarFromCode {
    if (@available(iOS 13.0, *)) {
        
        UIWindowScene *windowScene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
        return  windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
}

+ (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *carrierName = carrier.carrierName;
    return carrierName;
}

+(void)getCarrierInfo {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    if (carrier) {
        NSString *mobileCountryCode = carrier.mobileCountryCode;
        NSString *mobileNetworkCode = carrier.mobileNetworkCode;
        
        NSLog(@"Mobile Country Code: %@", mobileCountryCode);
        NSLog(@"Mobile Network Code: %@", mobileNetworkCode);
    } else {
        NSLog(@"无法获取运营商信息");
    }
}
@end
