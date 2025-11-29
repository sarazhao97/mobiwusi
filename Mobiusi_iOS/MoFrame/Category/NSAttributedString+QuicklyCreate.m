//
//  NSAttributedString+QuicklyCreate.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/18.
//

#import "NSAttributedString+QuicklyCreate.h"

@implementation NSAttributedString (QuicklyCreate)
+(instancetype)createWithString:(NSString *)str
                           font:(UIFont *)font
                      textColor:(UIColor *)textColor {
    
    NSAttributedString *attributedString = [[[self class] alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:textColor,NSFontAttributeName:font}];
    return attributedString;
}

+(instancetype)createWithString:(NSString *)str
                           font:(UIFont *)font
                      textColor:(UIColor *)textColor
                 paragraphStyle:(NSParagraphStyle *)paragraphStyle {
    
    NSAttributedString *attributedString = [[[self class] alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:textColor,NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}];
    return attributedString;
}
@end
