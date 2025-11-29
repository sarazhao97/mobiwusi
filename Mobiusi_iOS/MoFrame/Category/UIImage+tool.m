//
//  UIImage+tool.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/28.
//

#import "UIImage+tool.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <ImageIO/ImageIO.h>

@implementation UIImage (tool)
- (NSData *)getTifFormatImageData {
    NSMutableData *tiffData = [NSMutableData data];
    CGImageRef cgImage = self.CGImage;
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)tiffData, kUTTypeTIFF, 1, NULL);
    if (!destination) {
        NSLog(@"无法创建CGImageDestination.");
        return nil;
    }
    
    CGImageDestinationAddImage(destination, cgImage, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"无法完成图像数据写入.");
        CFRelease(destination);
        return nil;
    }
    
    CFRelease(destination);
    return tiffData;
}


- (NSData *)getGifFormatImageData {
    NSMutableData *gifData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)gifData, kUTTypeGIF, 1, NULL);
    CGImageDestinationAddImage(destination, self.CGImage, nil);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSData *finalData = [NSData dataWithData:gifData];
    return finalData;

}


-(NSData *)getHeicFormat {
    // 设置转换后的 HEIC 图像属性（这里设置压缩质量为 0.8）
    NSMutableDictionary *imageProperties = [NSMutableDictionary dictionary];
    [imageProperties setObject:@(0.8) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
    
    // 创建可变的 NSData 对象
    NSMutableData *heicData = [NSMutableData data];
    // 创建一个基于可变 Data 的 CGImageDestination，指定类型为 HEIC
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)heicData, kUTTypeGIF, 1, NULL);
    return nil;
}

- (UIImage *)resize:(CGSize)size {
	UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resizedImage;
}

@end
