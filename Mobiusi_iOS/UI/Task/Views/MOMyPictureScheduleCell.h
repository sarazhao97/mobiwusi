//
//  MOMyPictureScheduleCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOBaseScheduleCell.h"
#import "MOUserTaskDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOMyPictureScheduleCell : MOBaseScheduleCell
@property(nonatomic,strong)YYLabel *dataTitle;
@property(nonatomic,strong)MOView *attachmentImagesView;
@property(nonatomic,copy)void(^didPreviewClick)(NSInteger index);
-(void)configCellData:(MOUserTaskDataModel *)data;
@end

NS_ASSUME_NONNULL_END
