//
//  MOAudioVolumeAnalyzerOC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/11.
//

#import "MOAudioVolumeAnalyzerOC.h"
#import <CoreMedia/CoreMedia.h>
#import <CoreMedia/CMFormatDescription.h>
#import <Accelerate/Accelerate.h>
@implementation MOAudioVolumeAnalyzerOC


// 单例实例
+ (instancetype)shared {
	static MOAudioVolumeAnalyzerOC *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

// 私有初始化器
- (instancetype)init {
	self = [super init];
	if (self) {
		// 初始化代码
	}
	return self;
}


// 音频格式（单声道44.1kHz PCM）
- (AVAudioFormat *)pcmFormat {
	static AVAudioFormat *format = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
													sampleRate:44100
												  channels:1
											   interleaved:NO];
	});
	return format;
}

// 获取音频文件每10毫秒的音量数据
- (void)getVolumePer10msForFilePath:(NSURL *)filePath
							progress:(void(^)(double progress))progress
						  completion:(void(^)(NSDictionary<NSNumber *, NSNumber *> *volumeData, NSError *error))completion {

	if (!filePath) {
		NSError *error = [NSError errorWithDomain:@"InvalidInput" code:-1 userInfo:nil];
		if (completion) completion(nil, error);
		return;
	}

	AVAsset *asset = [AVAsset assetWithURL:filePath];
	NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
	NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
	
	if (audioTracks.count == 0) {
		NSError *error = [NSError errorWithDomain:@"NoAudioTrack" code:-2 userInfo:nil];
		if (completion) completion(nil, error);
		return;
	}

	dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
		NSError *readerError = nil;
		AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&readerError];
		if (readerError || !reader) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (completion) completion(nil, readerError);
			});
			return;
		}

		NSDictionary *readerSettings = @{
			AVFormatIDKey: @(kAudioFormatLinearPCM),
			AVLinearPCMBitDepthKey: @(16),
			AVLinearPCMIsBigEndianKey: @(NO),
			AVLinearPCMIsFloatKey: @(NO),
			AVLinearPCMIsNonInterleaved: @(NO) // ✅ 使用交错格式，避免重复采样
		};

		AVAssetTrack *audioTrack = audioTracks.firstObject;
		AVAssetReaderTrackOutput *trackReader = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:readerSettings];
		[reader addOutput:trackReader];
		DLog("duration : %f",asset.duration);
		reader.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);

		[reader startReading];

		NSMutableDictionary *volumeData = [NSMutableDictionary dictionary];

		// 获取采样率
		NSArray *formatDescriptions = audioTrack.formatDescriptions;
		CMFormatDescriptionRef fmtDesc = (__bridge CMFormatDescriptionRef)(formatDescriptions.firstObject);
		const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmtDesc);
		float sampleRate = asbd->mSampleRate;
		//判断通道数量
		int channelCount = asbd->mChannelsPerFrame;
		float timeInterval = 0.05;
		//判断通道数量，双通道采样需要 * 2
		int samplesPer10ms = (int)(sampleRate * timeInterval) * channelCount;

		NSMutableData *sampleBuffer = [NSMutableData data];
		NSTimeInterval currentTime = 0;

		while ([reader status] == AVAssetReaderStatusReading) {
			@autoreleasepool {
				CMSampleBufferRef sampleBufferRef = [trackReader copyNextSampleBuffer];
				if (!sampleBufferRef) break;

				NSLog(@"sampleBuffer.length: %lu bytes", (unsigned long)sampleBuffer.length);
				NSLog(@"sampleCount (int16_t samples): %lu", sampleBuffer.length / sizeof(int16_t));
//				NSLog(@"audioTrack.channelCount: %d", audioTrack);
				
				AudioBufferList audioBufferList;
				CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBufferRef);
				size_t length = 0;
				char *dataPointer = NULL;
				CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &length, &dataPointer);

				if (dataPointer && length > 0) {
					[sampleBuffer appendBytes:dataPointer length:length];
				}

				while (sampleBuffer.length >= samplesPer10ms * sizeof(int16_t)) {
					NSData *slice = [sampleBuffer subdataWithRange:NSMakeRange(0, samplesPer10ms * sizeof(int16_t))];
					float volume = [self calculateVolumeFromSampleBuffer:slice sampleCount:samplesPer10ms];
					volumeData[@((NSInteger)(currentTime * 1000))] = @((NSInteger)volume);
					currentTime += timeInterval;
					[sampleBuffer replaceBytesInRange:NSMakeRange(0, samplesPer10ms * sizeof(int16_t)) withBytes:NULL length:0];

					if (progress) {
						double p = MIN(1.0, currentTime / duration);
						dispatch_async(dispatch_get_main_queue(), ^{
							progress(p);
						});
					}
				}

				CFRelease(sampleBufferRef);
			}
		}

		if (sampleBuffer.length > 0) {
			int remainingSamples = (int)(sampleBuffer.length / sizeof(int16_t));
			float volume = [self calculateVolumeFromSampleBuffer:sampleBuffer sampleCount:remainingSamples];
			volumeData[@((NSInteger)(currentTime * 1000))] = @(volume);
		}

		[reader cancelReading];
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion([volumeData copy], nil);
			});
		}
	});
}



// 从样本缓冲区提取PCM数据
- (BOOL)extractPCMDataFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
						audioBufferList:(AudioBufferList *)audioBufferList {
	
	if (!sampleBuffer || !audioBufferList) {
			return NO;
		}
		
		// 创建临时的 AudioBufferList
	AudioBufferList *tempBufferList = NULL;
	UInt32 bufferListSize = 0;

	OSStatus status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
		sampleBuffer,
		&bufferListSize,
		NULL,
		0,
		NULL,
		NULL,
		0,
		NULL
	);
	
	if ( status != noErr) {
		
		return NO;
	}
	
	
//	tempBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList)+bufferListSize);
	tempBufferList = (AudioBufferList *)malloc(bufferListSize);
	if (!tempBufferList) {
		return NO;
	}
	// 初始化临时缓冲区
	
	
	tempBufferList->mNumberBuffers = 1;
	tempBufferList->mBuffers[0].mNumberChannels = 0;
	tempBufferList->mBuffers[0].mDataByteSize = 0;
	tempBufferList->mBuffers[0].mData = NULL;
	
	// 获取音频缓冲区列表
	CMBlockBufferRef blockBuffer = NULL;
	status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
		sampleBuffer,
		NULL,
		tempBufferList,
		bufferListSize,
		NULL, // 使用默认的 allocator
		NULL, // 需要保留的回调块
		kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, // 缓冲区对齐标志
		&blockBuffer // 需要保留的数据指针
	);
		
	if (status != noErr || tempBufferList->mBuffers[0].mData == NULL) {
		if (blockBuffer) {
			CFRelease(blockBuffer);
		}
		free(tempBufferList);
		return NO;
	}
	
		
	// 将临时缓冲区的数据复制到目标缓冲区
	*audioBufferList = *tempBufferList;
	
	// 释放临时缓冲区
	if (blockBuffer) {
			CFRelease(blockBuffer);
	}
	free(tempBufferList);
	
	return YES;
	
}





// 计算样本缓冲区的音量（RMS值）
- (float)calculateVolumeFromSampleBuffer:(NSData *)sampleBuffer sampleCount:(int)sampleCount {
	
	
	if (sampleBuffer.length == 0 || sampleCount <= 0) {
			return 0;
		}

		sampleCount = MIN(sampleCount, (int)(sampleBuffer.length / sizeof(int16_t)));
		const int16_t *samples = (const int16_t *)sampleBuffer.bytes;

		float *floatBuffer = (float *)malloc(sizeof(float) * sampleCount);
		if (!floatBuffer) return 0;

		vDSP_vflt16(samples, 1, floatBuffer, 1, sampleCount);
		float scale = 1.0 / 32768.0;
		vDSP_vsmul(floatBuffer, 1, &scale, floatBuffer, 1, sampleCount);
		vDSP_vsq(floatBuffer, 1, floatBuffer, 1, sampleCount);
		
		float mean = 0.0f;
		vDSP_meanv(floatBuffer, 1, &mean, sampleCount);
		
		free(floatBuffer);

		if (mean <= 1e-10f) {
			return 0;
		}

	float db = 10 * log10f(mean);

	float minDb = -50.0f; // 静音阈值
	float positiveDb = db - minDb;

	if (positiveDb < 0) positiveDb = 0;

	return positiveDb;
}

// 获取指定时间点的音量
- (void)getVolumeAtTime:(NSTimeInterval)time
			  filePath:(NSURL *)filePath
			completion:(void(^)(float volume, NSError *error))completion {
	// 验证输入
	if (time < 0 || !filePath) {
		NSError *error = [NSError errorWithDomain:@"InvalidInput" code:-1 userInfo:nil];
		if (completion) {
			completion(0.0, error);
		}
		return;
	}
	
	// 创建AVAsset
	AVAsset *asset = [AVAsset assetWithURL:filePath];
	
	// 检查是否包含音频轨道
	NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
	if (audioTracks.count == 0) {
		NSError *error = [NSError errorWithDomain:@"NoAudioTrack" code:-2 userInfo:nil];
		if (completion) {
			completion(0.0, error);
		}
		return;
	}
	
	// 在后台队列执行分析
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
		NSError *readerError = nil;
		AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&readerError];
		
		if (readerError || !reader) {
			if (completion) {
				dispatch_async(dispatch_get_main_queue(), ^{
					completion(0.0, readerError);
				});
			}
			return;
		}
		
		// 配置PCM输出格式
		NSDictionary *readerSettings = @{
			AVFormatIDKey: @(kAudioFormatLinearPCM),
			AVLinearPCMBitDepthKey: @(16),
			AVLinearPCMIsBigEndianKey: @(NO),
			AVLinearPCMIsFloatKey: @(NO),
			AVLinearPCMIsNonInterleaved: @(YES)
		};
		
		// 创建轨道输出
		AVAssetReaderTrackOutput *trackReader = [[AVAssetReaderTrackOutput alloc]
											   initWithTrack:audioTracks[0]
											outputSettings:readerSettings];
		[reader addOutput:trackReader];
		
		// 计算目标CMTime（带误差容忍范围）
		CMTime targetCMTime = CMTimeMakeWithSeconds(time, 44100);
		CMTime searchDuration = CMTimeMakeWithSeconds(0.2, 44100); // 搜索范围200ms
		CMTimeRange timeRange = CMTimeRangeMake(
			CMTimeSubtract(targetCMTime, searchDuration),
			searchDuration
		);
		reader.timeRange = timeRange;
		
		// 开始读取
		[reader startReading];
		float volume = 0.0;
		
		// 逐帧读取直到找到目标时间点附近的数据
		while ([reader status] == AVAssetReaderStatusReading) {
			CMSampleBufferRef sampleBuffer = [trackReader copyNextSampleBuffer];
			if (!sampleBuffer) {
				break;
			}
			
			// 获取当前样本的呈现时间
			CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
			NSTimeInterval currentTime = CMTimeGetSeconds(presentationTime);
			
			// 检查是否在目标时间附近（误差±50ms）
			if (fabs(currentTime - time) < 0.05) {
				// 提取PCM数据并计算音量
				AudioBufferList audioBufferList;
				if ([self extractPCMDataFromSampleBuffer:sampleBuffer audioBufferList:&audioBufferList]) {
					volume = [self calculateVolumeFromAudioBufferList:&audioBufferList];
				}
				break;
			}
			
			CFRelease(sampleBuffer);
		}
		
		[reader cancelReading];
		
		// 返回结果到主线程
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(volume, nil);
			});
		}
	});
}

// 计算AudioBufferList的音量（RMS值）
- (float)calculateVolumeFromAudioBufferList:(AudioBufferList *)audioBufferList {
	if (!audioBufferList || audioBufferList->mBuffers[0].mData == NULL || audioBufferList->mBuffers[0].mDataByteSize == 0) {
		return 0.0;
	}
	
	int16_t *samples = (int16_t *)audioBufferList->mBuffers[0].mData;
	int sampleCount = (int)(audioBufferList->mBuffers[0].mDataByteSize / sizeof(int16_t));
	
	float sumOfSquares = 0.0;
	
	for (int i = 0; i < sampleCount; i++) {
		float sample = (float)samples[i];
		sumOfSquares += sample * sample;
	}
	
	if (sampleCount > 0) {
		float rms = sqrtf(sumOfSquares / (float)sampleCount) / 32768.0f;
		return MIN(1.0f, MAX(0.0f, rms));
	}
	
	return 0.0;
}
@end
