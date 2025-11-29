//
//  UILabel+Fast.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "UILabel+Fast.h"

@implementation UILabel (Fast)

+(instancetype)labelWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = textColor;
    label.font = font;
    return label;
}
@end
