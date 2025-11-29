//
//  PHAsset+ProcessVideo.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/12.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (ProcessVideo)
-(void)proccessVideoWithComplete:(void(^)(NSURL *outputURL, BOOL success))complete;
@end

NS_ASSUME_NONNULL_END
