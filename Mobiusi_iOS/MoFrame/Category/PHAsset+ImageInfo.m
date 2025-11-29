//
//  PHAsset+ImageInfo.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/13.
//

#import "PHAsset+ImageInfo.h"

@implementation PHAsset (ImageInfo)
-(NSString *)getFormat{
    
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:self];
    for (PHAssetResource *resource in resources) {
        NSString *uti = resource.uniformTypeIdentifier;
        if ([uti isEqualToString:@"public.jpeg"]) {
            return @"jpeg";
        } else if ([uti isEqualToString:@"public.png"]) {
            return @"png";
        } else if ([uti isEqualToString:@"com.compuserve.gif"]) {
            return @"gif";
        } else if ([uti isEqualToString:@"public.tiff"]) {
            return @"tiff";
        } else if ([uti isEqualToString:@"public.heic"]) {
            return @"heic";
        } else if ([uti isEqualToString:@"public.heif"]) {
            return @"heif";
        }
    }
    return @"Unknown";
}
@end
