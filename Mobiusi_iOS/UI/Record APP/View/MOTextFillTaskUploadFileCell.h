//
//  MOTextFillTaskUploadFileCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import <UIKit/UIKit.h>
#import "MODocFileItemView.h"
#import "MOAttchmentFileInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOTextFillTaskUploadFileCell : UICollectionViewCell
@property(nonatomic,strong)MODocFileItemView *fileView;
@property(nonatomic,strong)MOButton *deleteBtn;
@property(nonatomic,copy)void(^didDeleteBtnClick)(void);
@property(nonatomic,strong)MOView *failurePromptView;
@property(nonatomic,copy)void(^didErrorIconClick)(void);
-(void)configCellWithModel:(MOAttchmentFileInfoModel *)model;
@end

NS_ASSUME_NONNULL_END
