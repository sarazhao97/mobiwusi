//
//  MOMyVoiceScheduleCell.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/3.
//

#import "MOMyVoiceScheduleCell.h"
@interface MOMyVoiceScheduleCell () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, assign) NSTimeInterval audioDuration;
@property (nonatomic, assign) BOOL isLocalAudio;
@property (nonatomic, strong) NSString *urlString; // 保存配置的URL
@property (nonatomic, strong) MOVoicePlayView *currentItem; // 保存配置的URL

@end

@implementation MOMyVoiceScheduleCell

- (void)addSubViews {
    
    [super addSubViews];
    [self.dataContentView.categoryDataView addSubview:self.dataTitle];
    self.dataTitle.preferredMaxLayoutWidth = SCREEN_WIDTH - 13 - 10 - 34 - 8;
    [self.dataTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(@(9));
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
    }];
    
    [self.dataContentView.categoryDataView addSubview:self.attachmentFilesView];
    [self.attachmentFilesView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(@(13));
        make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
    }];
    
    [self.dataContentView.categoryDataView addSubview:self.paramLabel];
    [self.paramLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13));
        make.top.equalTo(self.attachmentFilesView.mas_bottom).offset(8);
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
        make.bottom.equalTo(self.dataContentView.categoryDataView.mas_bottom).offset(-8);
    }];
}

- (void)configCellData:(MOUserTaskDataModel *)data {
    
    [self.attachmentFilesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self stop];
    
    self.timeLabel.text = data.upload_time;
    self.paramLabel.text = @"";
    if (data.topic_type == 1) {
        self.dataTitle.attributedText = [MOBaseScheduleCell createTryTagAttributedStringWithTitle:data.task_title.length ? data.task_title:data.idea];
    } else {
        self.dataTitle.attributedText = [MOBaseScheduleCell createNoTryTagAttributedStringWithTitle:data.task_title.length ? data.task_title:data.idea];
    }
	
	if (data.location.length > 0) {
		self.dataContentView.locationBtn.hidden = NO;
		[self.dataContentView.locationBtn setTitles:data.location];
	}else {
		self.dataContentView.locationBtn.hidden = YES;
	}
	
    self.dataContentView.redDotView.hidden = !data.is_not_read;
    NSInteger fileCount = data.result.count;
    self.dataContentView.didTageLabel.text = [NSString stringWithFormat:@"DID:%ld",(long)data.model_id];
    self.dataContentView.didTageLabel.hidden = YES;
    
    if (fileCount > 0) {
        MOVoicePlayView *fileItem = [MOVoicePlayView new];
        WEAKSELF
        fileItem.playClick = ^(BOOL boolValue) {
            if (boolValue == YES) {
                [weakSelf play];
            } else {
                [weakSelf stop];
            }
        };
        self.currentItem = fileItem;
        MOUserTaskDataResultModel *model = data.result[0];
		if (model.data_param.length > 0) {
			self.paramLabel.text = [NSString stringWithFormat:NSLocalizedString(@"音频参数：%@", nil), model.data_param];
		}
        
        self.urlString = model.path;
        self.audioDuration = model.duration/1000.f;
        [fileItem configWithUrl:model.path andDuration:model.duration];
        [self.attachmentFilesView addSubview:fileItem];
        [fileItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.attachmentFilesView.mas_top).offset(0);
            make.left.equalTo(self.attachmentFilesView.mas_left);
            make.right.equalTo(self.attachmentFilesView.mas_right);
            make.height.equalTo(@(35));
        }];
        // 计算高度时，设置为只有一个播放器
        fileCount = 1;
    }

    CGFloat maxY = fileCount *35 + (fileCount - 1)* 10;
    [self.attachmentFilesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13));
        make.top.equalTo(self.dataTitle.mas_bottom).offset(5);
        make.right.equalTo(self.dataContentView.categoryDataView.mas_right).offset(-10);
        make.height.equalTo(@(maxY));
    }];
}

- (void)play {
    if ([self isDeviceMuted] == YES) {
        [MBProgressHUD showMessag:NSLocalizedString(@"当前音量过小，请调大音量后播放", nil) toView:MOAppDelegate.window];
    }
    [self.delegate audioPlayerCellDidRequestPlay:self]; // 请求播放，交给ViewController管理
}

- (void)startPlaying {
    // 实际开始播放的逻辑
    NSURL *audioURL = [self.urlString hasPrefix:@"http"] ? [NSURL URLWithString:self.urlString] : [NSURL fileURLWithPath:self.urlString];
    self.isLocalAudio = ![self.urlString hasPrefix:@"http"];
    
    NSError *error;
    if (self.isLocalAudio) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        if (error) {
            DLog(@"本地音频初始化失败: %@", error.localizedDescription);
            return;
        }
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target:self
                                                            selector:@selector(updateLocalAudioProgress)
                                                            userInfo:nil
                                                             repeats:YES];
    } else {
        self.avPlayer = [[AVPlayer alloc] initWithURL:audioURL];
        [self.avPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        __weak typeof(self) weakSelf = self;
        [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                                    queue:dispatch_get_main_queue()
                                               usingBlock:^(CMTime time) {
            [weakSelf updateNetworkAudioProgress];
        }];
        
        // 添加播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidFinishPlaying:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.avPlayer.currentItem];
        
        [self.avPlayer play];
    }
}

- (void)pause {
    if (self.isLocalAudio) {
        [self.audioPlayer pause];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    } else {
        [self.avPlayer pause];
    }
}

- (void)stop {
    if (self.isLocalAudio) {
        [self.audioPlayer stop];
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        self.audioPlayer = nil;
    } else if (self.avPlayer) {
        [self.avPlayer pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                                              object:self.avPlayer.currentItem];
        @try {
            [self.avPlayer removeObserver:self forKeyPath:@"status"];
        } @catch (NSException *exception) {
            DLog(@"移除观察者失败: %@", exception);
        }
        self.avPlayer = nil;
    }
}

- (void)updatePlayingState:(BOOL)isPlaying {
    if (isPlaying) {
        [self startPlaying];
    } else {
        [self stop];
    }
}

#pragma mark - Progress Updates

- (void)updateLocalAudioProgress {
    if (self.audioPlayer.isPlaying) {
        if (self.audioDuration > 0) {
            float progress = self.audioPlayer.currentTime / self.audioDuration;
            [self.delegate audioPlayerCell:self didUpdateProgress:progress currentTime:self.audioPlayer.currentTime];
            [self.currentItem updatePlayProgress:progress andCurrentTime:self.audioPlayer.currentTime];
        }
    }
}

- (void)updateNetworkAudioProgress {
    if (self.avPlayer.rate > 0 && self.avPlayer.error == nil) {
        CMTime currentTime = self.avPlayer.currentTime;
        if (self.audioDuration > 0) {
            float progress = CMTimeGetSeconds(currentTime) / self.audioDuration;
            [self.currentItem updatePlayProgress:progress andCurrentTime:CMTimeGetSeconds(currentTime)];
            [self.delegate audioPlayerCell:self didUpdateProgress:progress currentTime:CMTimeGetSeconds(currentTime)];
        }
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.delegate audioPlayerCell:self didChangeState:@"Finished"];
    [self.currentItem endPlay];
    [self stop];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.delegate audioPlayerCell:self didChangeState:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
    [self.currentItem endPlay];
    [self stop];
}

#pragma mark - AVPlayer Notification

- (void)playerItemDidFinishPlaying:(NSNotification *)notification {
    DLog(@"网络音频播放完成");
    [self.delegate audioPlayerCell:self didChangeState:@"Finished"];
    [self.currentItem endPlay];
    [self stop];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.avPlayer.status) {
            case AVPlayerStatusReadyToPlay:
                [self.delegate audioPlayerCell:self didChangeState:@"Ready"];
                break;
            case AVPlayerStatusFailed:
                [self.delegate audioPlayerCell:self didChangeState:[NSString stringWithFormat:@"Failed: %@", self.avPlayer.error.localizedDescription]];
                break;
            case AVPlayerStatusUnknown:
                [self.delegate audioPlayerCell:self didChangeState:@"Unknown"];
                break;
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stop];
}

#pragma mark - setter && getter

-(YYLabel *)dataTitle {
    
    if (!_dataTitle) {
        _dataTitle = [YYLabel new];
        _dataTitle.numberOfLines = 0;
		_dataTitle.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    return _dataTitle;
}

- (UILabel *)paramLabel {
    if (!_paramLabel) {
        _paramLabel = [UILabel labelWithText:@"" textColor:[UIColor colorWithHexString:@"#828282"] font:MOPingFangSCMediumFont(11)];
    }
    return _paramLabel;
}

- (MOView *)attachmentFilesView {
    if (!_attachmentFilesView) {
        _attachmentFilesView = [MOView new];
    }
    return _attachmentFilesView;
}

#pragma mark - Audio State Checks

- (BOOL)isDeviceMuted {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 确保音频会话已激活并设置为播放模式
    NSError *error;
    if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback]) {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error) {
            NSLog(@"设置音频会话类别失败: %@", error.localizedDescription);
            return NO; // 默认返回非静音，防止误判
        }
    }
    [audioSession setActive:YES error:nil];
    
    // 获取当前音频路由
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    
    // 如果没有输出设备（例如拔掉耳机后无扬声器输出），认为是静音
    if (currentRoute.outputs.count == 0) {
        NSLog(@"无音频输出设备");
        return YES;
    }
    
    // 检查输出设备类型
    for (AVAudioSessionPortDescription *output in currentRoute.outputs) {
        // 如果是内置扬声器
        if ([output.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            float volume = audioSession.outputVolume; // 范围 0.0 - 1.0
            NSLog(@"当前音量: %.2f", volume);
            // 如果音量为0，且使用扬声器，通常是静音开关打开
            return (volume == 0.0);
        }
        // 如果是耳机、蓝牙等外部设备，静音开关不影响输出
        else if ([output.portType isEqualToString:AVAudioSessionPortHeadphones] ||
                 [output.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]) {
            return NO; // 耳机模式下，静音开关无效
        }
    }
    
    // 默认返回NO（非静音）
    return NO;
}


#pragma mark - dealloc
 
- (void)dealloc {
    [self stop];
}

@end
