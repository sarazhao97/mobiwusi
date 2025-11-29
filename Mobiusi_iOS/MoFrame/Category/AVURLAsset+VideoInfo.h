//
//  AVURLAsset+VideoInfo.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/12.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVURLAsset (VideoInfo)
+(instancetype)createVideoAssetWith:(NSURL *)videoURL;
-(UIImage *)getVideoThumbnail;
- (NSTimeInterval)getVideoDuration;
- (CGSize)getVideoResolution;
@end

NS_ASSUME_NONNULL_END
