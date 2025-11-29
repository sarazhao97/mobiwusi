//
//  MOFillTaskVideoCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import <UIKit/UIKit.h>
#import "MOAttchmentFileInfoModel.h"
#import "MOVideoInfoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOFillTaskVideoCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)MOButton *deleteBtn;
@property(nonatomic,strong)UIImageView *suspendImageView;
@property(nonatomic,strong)MOView *failurePromptView;
@property(nonatomic,copy)void(^didDeleteBtnClick)(void);
@property(nonatomic,copy)void(^didErrorIconClick)(void);
-(void)configImageCellWithModel:(MOAttchmentImageFileInfoModel *)model;
-(void)configVideoCellWithModel:(MOAttchmentVideoFileInfoModel *)model;
@end

NS_ASSUME_NONNULL_END
