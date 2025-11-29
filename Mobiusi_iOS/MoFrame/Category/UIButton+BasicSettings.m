//
//  UIButton+BasicSettings.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/18.
//

#import "UIButton+BasicSettings.h"

@implementation UIButton (BasicSettings)

-(void)setTitle:(NSString * _Nullable)title  titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor font:(UIFont *)font {
    
    [self setTitle:title titleColor:titleColor bgColor:bgColor forState:UIControlStateNormal];
    [self setTitle:title  titleColor:titleColor bgColor:bgColor forState:UIControlStateHighlighted];
    self.titleLabel.font = font;
}

-(void)setTitle:(NSString * _Nullable)title
     titleColor:(UIColor *)titleColor
        bgColor:(UIColor *)bgColor
       forState:(UIControlState)state  {
    
    [self setTitle:title forState:state];
    [self setTitleColor:titleColor forState:state];
    [self setBackgroundColor:bgColor];
    
}


-(void)setImage:(UIImage *)image {
    
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
}

-(void)setImage:(UIImage *)image selectImage:(UIImage *)selectImage{
	
	[self setImage:image forState:UIControlStateNormal];
	[self setImage:image forState:UIControlStateHighlighted];
	[self setImage:selectImage forState:UIControlStateSelected];
}

-(void)setTitles:(NSString * _Nullable)title {
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
	[self setTitle:title forState:UIControlStateSelected];
}

-(void)centerImageAboveTitle:(CGFloat)padding {
	
	if (!self.imageView || !self.titleLabel) {
		return;
	}
	[self layoutIfNeeded];
	CGSize imageSize = self.imageView.frame.size;
	CGSize titleSize = self.titleLabel.frame.size;
	CGFloat totalHeight = imageSize.height + titleSize.height + padding;
	
	self.imageEdgeInsets = UIEdgeInsetsMake(-(totalHeight - imageSize.height), 0, 0, -titleSize.width);
	self.titleEdgeInsets = UIEdgeInsetsMake(0,-imageSize.width,-(totalHeight - titleSize.height),0);
	
	self.contentEdgeInsets = UIEdgeInsetsMake((totalHeight - imageSize.height - titleSize.height) / 2,0,(totalHeight - imageSize.height - titleSize.height) / 2,0);
}
@end
