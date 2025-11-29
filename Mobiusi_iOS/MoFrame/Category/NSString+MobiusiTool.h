//
//  NSString+MobiusiTool.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MobiusiTool)
+(NSString *)numberOfPeopleToStringWithUnit:(NSInteger)numberOfPeople;
-(BOOL)isRegisterPwd;
-(NSString *)phoneNumberMask;
+ (NSString *)mimeTypeForExtension:(NSString *)fileExtension;
@end

NS_ASSUME_NONNULL_END
