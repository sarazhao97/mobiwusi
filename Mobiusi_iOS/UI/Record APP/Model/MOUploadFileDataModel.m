//
//  MOUploadFileDataModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/26.
//

#import "MOUploadFileDataModel.h"

@implementation MOUploadFileDataModel
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{@"model_id" : @"id"};
}

@end


@implementation MOUploadPictureFileDataModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.device = @"iphone";
    }
    return self;
}
@end


@implementation MOUploadVideoFileDataModel
@end

@implementation MOUploadAudioFileDataModel
@end
