//
//  MOPictureVideoFillTaskStep2View.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOPictureVideoFillTaskStep2View : MOView
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOButton *exampleBtn;
@property(nonatomic,strong)UICollectionView *pictureVideoCollectionView;
@property(nonatomic,copy)void(^didExampleBtnClick)(void);
@end

NS_ASSUME_NONNULL_END
