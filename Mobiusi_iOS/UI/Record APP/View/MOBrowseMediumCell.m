//
//  MOBrowseMediumCell.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/28.
//

#import "MOBrowseMediumCell.h"

@implementation MOBrowseMediumCell


-(instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		if (@available(iOS 14.0, *)) {
			self.backgroundConfiguration = [UIBackgroundConfiguration clearConfiguration];
		}
		[self addSubviews];
	}
	
	return self;
}

-(void)layoutSubviews {
	[super layoutSubviews];
	if (self.videoPlayerLayer.bounds.size.width != self.videoPlayerView.frame.size.width ||
		self.videoPlayerLayer.bounds.size.height != self.videoPlayerView.frame.size.height) {
		self.videoPlayerLayer.frame = self.videoPlayerView.bounds;
	}
}

-(void)addSubviews {
	
	[self.contentView addSubview:self.videoPlayerView];
	[self.videoPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.contentView);
	}];
	
	self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	[self.videoPlayerView.layer addSublayer:self.videoPlayerLayer];
	
	
	// 创建长按手势识别器
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	// 设置长按时间（可选，默认0.5秒）
//	longPressGesture.minimumPressDuration = 1.0;
	[self.imageViewConentView addGestureRecognizer:longPressGesture];
	[self.contentView addSubview:self.imageViewConentView];
	self.imageViewConentView.delegate = self;
	self.imageViewConentView.minimumZoomScale = 0.2;
	self.imageViewConentView.maximumZoomScale = 10;
	[self.imageViewConentView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.contentView);
	}];
	[self.imageViewConentView addSubview:self.imageView];
	[self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.imageViewConentView);
		make.width.equalTo(@(SCREEN_WIDTH));
		make.height.equalTo(@(SCREEN_HEIGHT));
	}];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
	switch (gesture.state) {
		case UIGestureRecognizerStateBegan:
			if (self.didLongPressImage) {
				self.didLongPressImage();
			}
			break;
			
		default:
			break;
	}
}

-(void)didPlayEnd {
    [self.videoPlayer seekToTime:kCMTimeZero];
    [self.videoPlayer play];
}



-(void)configCellWithModel:(MOBrowseMediumItemModel *)model {
    
    
    if (model.type == MOBrowseMediumItemTypeImage) {
        self.videoPlayerView.hidden = YES;
        self.imageView.clipsToBounds = YES;
        self.imageViewConentView.hidden = NO;
        if (model.url) {
            WEAKSELF
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.url?:@""] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            }];
        }else {
            self.imageView.image = model.image;
        }
        
    } else {
        self.imageViewConentView.hidden = YES;
        self.videoPlayerView.hidden = NO;
        NSURL *videoURL = [NSURL URLWithString:model.url?:@""];
        [self setupPlayerWithURL:videoURL];
    }
}

- (void)setupPlayerWithURL:(NSURL *)videoURL {
    // 移除旧的 playerLayer
    if (self.videoPlayerLayer) {
        [self.videoPlayerLayer removeFromSuperlayer];
        self.videoPlayerLayer = nil;
    }
    
    // 停止旧的 player 并释放资源
    if (self.videoPlayer) {
        [self.videoPlayer pause];
        self.videoPlayer = nil;
    }
    
    // 创建新的 AVPlayer
    self.videoPlayer = [AVPlayer playerWithURL:videoURL];
    
    // 创建新的 AVPlayerLayer
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    
    // 设置 AVPlayerLayer 的属性和位置
    self.videoPlayerLayer.frame = self.videoPlayerView.bounds;
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.videoPlayerView.layer addSublayer:self.videoPlayerLayer];
    
    
    // 播放视频
//    [self.videoPlayer play];
}


- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
	CGSize scrollViewSize = scrollView.bounds.size;
	CGSize containerSize = scrollView.contentSize;

	CGFloat horizontalInset = MAX((scrollViewSize.width - containerSize.width ) / 2, 0);
	CGFloat verticalInset = MAX((scrollViewSize.height - containerSize.height) / 2, 0);

	scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
	[scrollView setNeedsLayout];
	[self.imageView setNeedsLayout];
}


#pragma mark - setter && getter
-(UIScrollView *)imageViewConentView {
    if (!_imageViewConentView) {
        _imageViewConentView = [UIScrollView new];
        _imageViewConentView.showsVerticalScrollIndicator = NO;
        _imageViewConentView.showsHorizontalScrollIndicator = NO;
        _imageViewConentView.backgroundColor = ClearColor;
    }
    return _imageViewConentView;
}

-(UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
		_imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

-(MOView *)videoPlayerView {
    
    if (!_videoPlayerView) {
        _videoPlayerView = [[MOView alloc] init];
    }
    
    return _videoPlayerView;
}

@end
