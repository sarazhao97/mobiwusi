//
//  NSAttributedString+QuicklyCreate.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (QuicklyCreate)
+(instancetype)createWithString:(NSString *)str
                           font:(UIFont *)font
                      textColor:(UIColor *)textColor;

+(instancetype)createWithString:(NSString *)str
                           font:(UIFont *)font
                      textColor:(UIColor *)textColor
                 paragraphStyle:(NSParagraphStyle *)paragraphStyle;
@end

NS_ASSUME_NONNULL_END
