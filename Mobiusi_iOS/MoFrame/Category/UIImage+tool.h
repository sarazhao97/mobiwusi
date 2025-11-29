//
//  UIImage+tool.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (tool)
- (NSData *)getTifFormatImageData;
- (NSData *)getGifFormatImageData;
- (UIImage *)resize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
