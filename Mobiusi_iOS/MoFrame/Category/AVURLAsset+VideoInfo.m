//
//  AVURLAsset+VideoInfo.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/12.
//

#import "AVURLAsset+VideoInfo.h"

@implementation AVURLAsset (VideoInfo)
-(UIImage *)getVideoThumbnail{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error;
    CMTime actualTime;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (imageRef) {
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return thumbnail;
    }
    return nil;
}

+(instancetype)createVideoAssetWith:(NSURL *)videoURL{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset*urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    return urlAsset;
}

- (NSTimeInterval)getVideoDuration{
    NSTimeInterval floatsecond = self.duration.value/ self.duration.timescale;
    return floatsecond;
}

- (CGSize)getVideoResolution {
    AVAssetTrack *videoTrack = [[self tracksWithMediaType:AVMediaTypeVideo] firstObject];
    return videoTrack.naturalSize;
}
@end
