//
//  MOMicAnimationView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOMicAnimationView : UIView
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *innercircleColor;

- (void)updateMeters:(CGFloat)progress;
@end

NS_ASSUME_NONNULL_END
