//
//  MOAudioVolumeAnalyzerOC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOAudioVolumeAnalyzerOC : NSObject
// 单例方法
+ (instancetype)shared;

// 获取指定时间点的音量
- (void)getVolumeAtTime:(NSTimeInterval)time
			  filePath:(NSURL *)filePath
			completion:(void(^)(float volume, NSError *error))completion;

// 获取音频文件每10毫秒的音量数据
- (void)getVolumePer10msForFilePath:(NSURL *)filePath
						  progress:(void(^)(double progress))progress
						completion:(void(^)(NSDictionary<NSNumber *, NSNumber *> *volumeData, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
