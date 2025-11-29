//
//  MOPictureVideoStep2HeaderView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOPictureVideoStep2HeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MOButton  *completeBtn;

-(void)setWanringTitle:(NSString *)title;
-(void)setSuccessTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
