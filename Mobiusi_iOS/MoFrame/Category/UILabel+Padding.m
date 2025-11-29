//
//  UILabel+Padding.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/20.
//

#import "UILabel+Padding.h"
#import <objc/runtime.h>
static const char *kTextInsetsKey = "kTextInsetsKey";

@implementation UILabel (Padding)
- (UIEdgeInsets)textInsets {
	NSValue *value = objc_getAssociatedObject(self, kTextInsetsKey);
	return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setTextInsets:(UIEdgeInsets)textInsets {
	objc_setAssociatedObject(self, kTextInsetsKey, [NSValue valueWithUIEdgeInsets:textInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self setNeedsDisplay];
	[self invalidateIntrinsicContentSize];
}
+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Method originalMethod = class_getInstanceMethod(self, @selector(drawTextInRect:));
		Method swizzledMethod = class_getInstanceMethod(self, @selector(padding_drawTextInRect:));
		method_exchangeImplementations(originalMethod, swizzledMethod);
		
		Method original1 = class_getInstanceMethod(self, @selector(sizeThatFits:));
		Method swizzled1 = class_getInstanceMethod(self, @selector(padding_sizeThatFits:));
		method_exchangeImplementations(original1, swizzled1);
		
		Method original2 = class_getInstanceMethod(self, @selector(intrinsicContentSize));
		Method swizzled2 = class_getInstanceMethod(self, @selector(padding_intrinsicContentSize));
		method_exchangeImplementations(original2, swizzled2);
		
	});
}

- (void)padding_drawTextInRect:(CGRect)rect {
	[self padding_drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textInsets)];
}

- (CGSize)padding_sizeThatFits:(CGSize)size {
	CGSize baseSize = [self padding_sizeThatFits:size];
	UIEdgeInsets insets = self.textInsets;
	baseSize.width += insets.left + insets.right;
	baseSize.height += insets.top + insets.bottom;
	return baseSize;
}
- (CGSize)padding_intrinsicContentSize {
	CGSize baseSize = [self padding_intrinsicContentSize];
	UIEdgeInsets insets = self.textInsets;
	baseSize.width += insets.left + insets.right;
	baseSize.height += insets.top + insets.bottom;
	return baseSize;
}

@end
