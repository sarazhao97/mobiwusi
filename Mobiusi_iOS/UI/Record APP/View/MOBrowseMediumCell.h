//
//  MOBrowseMediumCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import <UIKit/UIKit.h>
#import "MOBrowseMediumItemModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOBrowseMediumCell : UICollectionViewCell<UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *imageViewConentView;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)MOView *videoPlayerView;
@property(nonatomic,strong,nullable)AVPlayer *videoPlayer;
@property(nonatomic,strong,nullable)AVPlayerLayer *videoPlayerLayer;
@property(nonnull,copy)void(^didLongPressImage)(void);
-(void)configCellWithModel:(MOBrowseMediumItemModel *)model;
@end

NS_ASSUME_NONNULL_END
