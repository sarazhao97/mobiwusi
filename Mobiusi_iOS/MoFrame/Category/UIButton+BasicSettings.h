//
//  UIButton+BasicSettings.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (BasicSettings)
-(void)setTitle:(NSString * _Nullable)title  titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor font:(UIFont *)font;
-(void)setTitle:(NSString * _Nullable)title
     titleColor:(UIColor *)titleColor
        bgColor:(UIColor *)bgColor
       forState:(UIControlState)state;

-(void)setImage:(UIImage * _Nullable)image;
-(void)setImage:(UIImage *)image selectImage:(UIImage *)selectImage;
-(void)setTitles:(NSString * _Nullable)title;
-(void)centerImageAboveTitle:(CGFloat)padding;
@end

NS_ASSUME_NONNULL_END
