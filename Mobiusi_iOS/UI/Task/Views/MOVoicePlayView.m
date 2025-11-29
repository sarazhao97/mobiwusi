//
//  MOVoicePlayView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/3.
//

#import "MOVoicePlayView.h"

@interface MOVoicePlayView ()
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *progressImageView;
@property (nonatomic, strong) UIView *progressParentView;

@property (nonatomic, strong) UIImageView *progressBgImageView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, assign) NSInteger duration;


@end

@implementation MOVoicePlayView

- (void)addSubViewsInFrame:(CGRect)frame {
    [super addSubViewsInFrame:frame];
        
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.bgView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.left.equalTo(self.bgView).mas_offset(14);
        make.width.height.mas_equalTo(22);//
    }];
    
    [self.bgView addSubview:self.durationLabel];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton);
        make.right.equalTo(self.bgView).mas_offset(-14);
    }];
    
    [self.bgView addSubview:self.progressBgImageView];
    [self.progressBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).mas_offset(10);
        make.right.equalTo(self.bgView).mas_offset(-60);
        make.height.equalTo(self.progressBgImageView.mas_width).multipliedBy(0.07);
        make.centerY.equalTo(self.durationLabel);
    }];
    
    [self.bgView addSubview:self.progressParentView];
    [self.progressParentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.progressBgImageView);
        make.width.mas_equalTo(0);
    }];
    
    [self.progressParentView addSubview:self.progressImageView];
    [self.progressImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.progressParentView);
        make.width.height.equalTo(self.progressBgImageView);
    }];
}

- (void)configWithUrl:(NSString *)url andDuration:(NSInteger)duration {
	
    self.playUrl = url;
    self.duration = duration;
    NSInteger seconds = duration/1000;
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", seconds/60, seconds%60];
}

- (void)playButtonClick {
    self.playButton.selected = !self.playButton.selected;
    if (self.playClick) {
        self.playClick(self.playButton.selected);
    }
}

- (void)updatePlayProgress:(CGFloat)progress andCurrentTime:(NSInteger)currentTime {
    NSInteger seconds = self.duration/1000-currentTime;
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", seconds/60, seconds%60];
    
    if (progress > 0.f && progress < 1.f) {
        self.playButton.selected = YES;
    } else {
        self.playButton.selected = NO;
    }
    
    CGFloat width = self.frame.size.width-14-22-10-60;
    DLog(@"width - %f ; progress:%f", width,progress);
    [self.progressParentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width*progress);
    }];
}

- (void)endPlay {
    NSInteger seconds = self.duration/1000;
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", seconds/60, seconds%60];
    self.playButton.selected = NO;
    [self.progressParentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
    }];
}

- (void)dealloc {
    // 清理定时器
    if (self.animationTimer) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
}

#pragma mark - setter && getter

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#EDEEF5"];
        _bgView.layer.cornerRadius = 15.f;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (MOButton *)playButton {
    if (_playButton == nil) {
        _playButton = [MOButton new];
        [_playButton setImage:[UIImage imageNamedNoCache:@"icon_record_my_voice_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamedNoCache:@"icon_record_my_voice_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _playButton;
}

- (UILabel *)durationLabel {
    if (_durationLabel == nil) {
        _durationLabel = [UILabel new];
        _durationLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        _durationLabel.font = [UIFont systemFontOfSize:10];
        _durationLabel.text = @"00:00";
    }
    return _durationLabel;
}

- (UIImageView *)progressBgImageView {
    if (_progressBgImageView == nil) {
        _progressBgImageView = [UIImageView new];
        _progressBgImageView.image = [UIImage imageNamedNoCache:@"icon_record_my_voice_playing_g"];
        _progressBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _progressBgImageView.clipsToBounds = YES;
    }
    return _progressBgImageView;
}

- (UIView *)progressParentView {
    if (_progressParentView == nil) {
        _progressParentView = [UIView new];
        _progressParentView.backgroundColor = [UIColor clearColor];
        _progressParentView.layer.masksToBounds = YES;
    }
    return _progressParentView;
}

- (UIImageView *)progressImageView {
    if (_progressImageView == nil) {
        _progressImageView = [UIImageView new];
        _progressImageView.image = [UIImage imageNamedNoCache:@"icon_record_my_voice_playing_r"];
        _progressImageView.contentMode = UIViewContentModeScaleAspectFill;
        _progressImageView.clipsToBounds = YES;
    }
    return _progressImageView;
}

@end
