//
//  PHAsset+ProcessVideo.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/12.
//

#import "PHAsset+ProcessVideo.h"
#import <TZImagePickerController.h>
#define TmpSaveVideoDirectory  @"tmpSaveVideo"
@implementation PHAsset (ProcessVideo)
-(void)proccessVideoWithComplete:(void(^)(NSURL *outputURL, BOOL success))complete {
    
    if (self.mediaType != PHAssetMediaTypeVideo) {
        if (complete) {
            complete(nil,false);
        }
        return;
    }
    __weak typeof(self)weakSelf = self;
    [[TZImageManager manager] getVideoWithAsset:self completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        AVURLAsset *tmp = (AVURLAsset *)playerItem.asset;
        if ([[tmp.URL.pathExtension lowercaseString] isEqualToString:@"mp4"]) {
            
            [self downloadVideoWith:tmp.URL completion:^(NSURL *outputURL, BOOL success) {
                
                if (complete) {
                    complete(outputURL,success);
                }
            }];
            
        } else {
            [weakSelf convertMOVToMP4:tmp.URL completion:^(NSURL *outputURL, BOOL success) {
                if (complete) {
                    complete(outputURL,success);
                }
                
            }];
        }
    }];
}

-(void)downloadVideoWith:(NSURL *)inputURL completion:(void (^)(NSURL *outputURL, BOOL success))completion {
    
    NSString *outputPath = [self createTmpSaveVideoPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[NSUUID UUID].UUIDString];
    outputPath = [outputPath stringByAppendingPathComponent:fileName];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    // 创建NSURLSessionConfiguration对象
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 设置缓存策略为NSURLRequestReturnCacheDataElseLoad
    configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    // 创建NSURLSession对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    // 创建NSURLRequest对象
    NSURLRequest *request = [NSURLRequest requestWithURL:inputURL];
    // 发起网络请求
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion(outputURL,YES);
            } else {
                [data writeToURL:outputURL atomically:YES];
                if (completion) {
                    completion(outputURL,YES);
                }
            }
        });
        
    }];
    [task resume];
    
}


- (void)convertMOVToMP4:(NSURL *)inputURL completion:(void (^)(NSURL *outputURL, BOOL success))completion {
    AVAsset *asset = [AVAsset assetWithURL:inputURL];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    NSString *outputPath = [self createTmpSaveVideoPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[NSUUID UUID].UUIDString];
    outputPath = [outputPath stringByAppendingPathComponent:fileName];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted:
                    completion(outputURL, YES);
                    break;
                case AVAssetExportSessionStatusFailed:
                    DLog(@"视频转换失败: %@", exportSession.error.localizedDescription);
                    completion(nil, NO);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    DLog(@"视频转换取消");
                    completion(nil, NO);
                    break;
                default:
                    completion(nil, NO);
                    break;
            }
        });
        
    }];
}


-(NSString *)createTmpSaveVideoPath{
    
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:TmpSaveVideoDirectory];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:NULL error:NULL];
    } else {
        if (!isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:NULL error:NULL];
        }
    }
    return outputPath;
}
@end
