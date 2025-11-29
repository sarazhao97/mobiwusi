//
//  MOAlbumOperationTopicVC.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import "MOBaseFillTaskTopicTemplateVC.h"
#import "MOPictureVideoFillTaskStep2View.h"
#import "MOPictureVideoStep2PlaceholderCell.h"
#import "MOPictureVideoStep2HeaderView.h"
#import "MOOnlyTextStepView.h"
#import "UIImagePickerController+Block.h"
#import "MOFillTaskVideoCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOAlbumOperationTopicVC : MOBaseFillTaskTopicTemplateVC<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong,readonly) MOPictureVideoFillTaskStep2View *step2View;
@property (nonatomic, strong) MOOnlyTextStepView *step3View;
@end

NS_ASSUME_NONNULL_END
