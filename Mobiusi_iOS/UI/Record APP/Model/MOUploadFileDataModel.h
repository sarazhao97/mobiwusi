//
//  MOUploadFileDataModel.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/26.
//

#import "MOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOUploadFileDataModel : MOModel
@property(nonatomic,assign)NSInteger model_id;
@property(nonatomic,copy)NSString* file_name;
@property(nonatomic,copy)NSString* format;
@property(nonatomic,assign)NSInteger size;
@property(nonatomic,copy,nullable)NSString* url;
@property(nonatomic,copy,nullable)NSString* fullUrl;
@end

@interface MOUploadPictureFileDataModel : MOUploadFileDataModel
@property(nonatomic,copy)NSString* quality;
@property(nonatomic,copy)NSString* device;
@property(nonatomic,copy,nullable)NSString* location;
@end

@interface MOUploadVideoFileDataModel : MOUploadFileDataModel
@property(nonatomic,copy)NSString* quality;
@property(nonatomic,assign)NSInteger duration;
@end

@interface MOUploadAudioFileDataModel : MOUploadFileDataModel
@property(nonatomic,assign)NSInteger duration;
@end

NS_ASSUME_NONNULL_END
