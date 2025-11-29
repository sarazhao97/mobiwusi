//
//  MOAttchmentFileInfoModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOModel.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface MOAttchmentFileInfoModel : MOModel
@property(nonatomic,assign)NSInteger fileId;
@property(nonatomic,strong,nullable)NSString *fileServerUrl;
@property(nonatomic,strong,nullable)NSString *fileServerRelativeUrl;
@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSString *fileExtension;
@property(nonatomic,strong,nullable)NSData *fileData;
@property(nonatomic,assign)NSInteger fileStatus;
@property(nonatomic,strong)NSString *errorMsg;
@end

@interface MOAttchmentImageFileInfoModel : MOAttchmentFileInfoModel
@property(nonatomic,strong,nullable)UIImage *image;
@property(nonatomic,strong,nullable)PHAsset *imageAsset;
@property(nonatomic,copy)NSString *quality;
@property(nonatomic,copy)NSString *location;
@end

@interface MOAttchmentVideoFileInfoModel : MOAttchmentFileInfoModel
@property(nonatomic,strong)UIImage *thumbnail;
@property(nonatomic,copy)NSString *thumbnailUrl;
@property(nonatomic,strong)NSURL *locationMediaURL;
@property(nonatomic,copy)NSString *quality;
@property(nonatomic,strong,nullable)PHAsset *videoAsset;
@property(nonatomic,assign)NSInteger duration;
@end

@interface MOAttchmentAudioFileInfoModel : MOAttchmentFileInfoModel
@property(nonatomic,strong)NSURL *locationMediaURL;
@property(nonatomic,assign)NSInteger duration;
@end

NS_ASSUME_NONNULL_END
