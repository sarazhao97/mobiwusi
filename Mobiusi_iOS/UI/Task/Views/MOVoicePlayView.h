//
//  MOVoicePlayView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/3.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOVoicePlayView : MOView

@property (nonatomic, copy) MOBoolBlock playClick;
@property (nonatomic, strong) MOButton *playButton;
- (void)configWithUrl:(NSString *)url andDuration:(NSInteger)duration;
- (void)updatePlayProgress:(CGFloat)progress andCurrentTime:(NSInteger)currentTime;
- (void)endPlay;
- (void)pausePlay;
- (void)resumePlay;

@end

NS_ASSUME_NONNULL_END
