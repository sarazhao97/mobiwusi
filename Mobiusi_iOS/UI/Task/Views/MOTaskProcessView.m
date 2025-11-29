//
//  MOTaskProcessView.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/28.
//

#import "MOTaskProcessView.h"

@implementation MOTaskProcessView

-(void)addSubViewsInFrame:(CGRect)frame {
    
//    [self addSubview:self.titleLabel];
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.left.equalTo(self.mas_left).offset(20);
//        make.top.equalTo(self.mas_top).offset(19);
//    }];
    self.titleLabel.hidden = YES;
    
    
    [self addSubview:self.markView];
//    [self.markView cornerRadius:QYCornerRadiusAll radius:10];
    [self.markView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(11);
        make.right.equalTo(self.mas_right).offset(-11);
        make.height.equalTo(@(1));
        make.top.equalTo(self.mas_top).offset(13);
//        make.centerY.equalTo(self.titleLabel.mas_centerY);
    }];
    
    
    
    [self addSubview:self.processView];
    [self.processView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.markView.mas_bottom).offset(10);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.height.equalTo(@(69));
    }];
}

-(void)configViewWithModel:(MOTaskDetailNewModel *)model{
    
    [self.processView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *subTitles = @[].mutableCopy;
    NSMutableArray *states = @[].mutableCopy;
    NSMutableArray *progressBar = @[].mutableCopy;
    if (model.is_try == 1) {
        NSArray *currentTitles = @[NSLocalizedString(@"完成测试数据", nil),NSLocalizedString(@"测试通过", nil), NSLocalizedString(@"完成正式数据", nil),NSLocalizedString(@"初审通过", nil),NSLocalizedString(@"终审通过", nil),NSLocalizedString(@"待支付", nil),NSLocalizedString(@"已支付", nil)];
        
        if (model.try_status == 0) {
            [states addObjectsFromArray:
                 @[
                @(model.is_get?TaskStateInProgress:TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
            
        }
        
        if (model.try_status == 2) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateCompletedTestData),
                @(TaskStateFail),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createFail],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        if (model.try_status == 3) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateCompletedTestData),
                @(TaskStateInReview),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createInReview],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        //试做已完成的
        if (model.try_status == 1) {
            
            if ([model.task_status integerValue] == 0 ) {
                [states addObjectsFromArray:
                     @[
                    @(TaskStateInProgress),
                    @(TaskStateApproved),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
					@(TaskStateNotStarted),
                    ]
                ];
                
                [subTitles addObjectsFromArray:currentTitles];
                [progressBar addObjectsFromArray:
                 @[
                    [MOProcessView createSuccess],
                    [MOProcessView createInProcess],
                    [MOProcessView createNormal],
                    [MOProcessView createNormal],
                    [MOProcessView createNormal],
					[MOProcessView createNormal],
                 ]
                ];
                
            }
            
            
            if ([model.task_status integerValue] == 1) {
                [states addObjectsFromArray:
                     @[
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateInProgress),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
					@(TaskStateNotStarted),
                    ]
                ];
                
                [subTitles addObjectsFromArray:currentTitles];
                [progressBar addObjectsFromArray:
                 @[
                    [MOProcessView createSuccess],
                    [MOProcessView createInProcess],
                    [MOProcessView createNormal],
                    [MOProcessView createNormal],
                    [MOProcessView createNormal],
					[MOProcessView createNormal],
                 ]
                ];
                
            }
            
            if ([model.task_status integerValue] == 2) {
                [states addObjectsFromArray:
                     @[
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateInReview),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
					@(TaskStateNotStarted),
                    ]
                ];
                [subTitles addObjectsFromArray:currentTitles];
                [progressBar addObjectsFromArray:
                 @[
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    [MOProcessView createInReview],
                    [MOProcessView createNormal],
                    [MOProcessView createNormal],
					[MOProcessView createNormal],
                 ]
                ];
            }
            
            if ([model.task_status integerValue] == 3) {
                [states addObjectsFromArray:
                     @[
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateFail),
                    @(TaskStateNotStarted),
                    @(TaskStateNotStarted),
					@(TaskStateNotStarted),
                    ]
                ];
                
                [subTitles addObjectsFromArray:currentTitles];
                [progressBar addObjectsFromArray:
                 @[
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    [MOProcessView createFail],
                    [MOProcessView createNormal],
                    [MOProcessView createNormal],
					[MOProcessView createNormal],
                 ]
                ];
            }
            
            if ([model.task_status integerValue] == 4) {
                [states addObjectsFromArray:
                     @[
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateInProgress),
                    @(TaskStateNotStarted),
					@(TaskStateNotStarted),
                    ]
                ];
                
                [subTitles addObjectsFromArray:currentTitles];
                [progressBar addObjectsFromArray:
                 @[
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    [MOProcessView createInProcess],
                    [MOProcessView createNormal],
					[MOProcessView createNormal],
                 ]
                ];
            }
            
            if ([model.task_status integerValue] == 5) {
                [states addObjectsFromArray:
                     @[
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    @(TaskStateApproved),
                    model.is_pay == 0?@(TaskStateInProgress):@(TaskStateApproved),
					model.is_pay == 0?@(TaskStateNotStarted):@(TaskStateApproved),
                    ]
                ];
                
                [subTitles addObjectsFromArray:currentTitles];
                [progressBar addObjectsFromArray:
                 @[
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    [MOProcessView createSuccess],
                    model.is_pay == 0?[MOProcessView createInReview]:[MOProcessView createSuccess],
					model.is_pay == 0?[MOProcessView createNormal]:[MOProcessView createSuccess],
                 ]
                ];
            }
            
            
        }
        
        
        
    }
    
    
    if (model.is_try == 0){
        
        NSArray *currentTitles = @[NSLocalizedString(@"完成正式数据", nil),NSLocalizedString(@"初审通过", nil),NSLocalizedString(@"终审通过", nil),NSLocalizedString(@"待支付", nil),NSLocalizedString(@"已支付", nil)];
        if ([model.task_status integerValue] == 0) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        
        if ([model.task_status integerValue] == 1 ) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createNormal],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        
        if ([model.task_status integerValue] == 2) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateApproved),
                @(TaskStateInReview),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createInReview],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        
        if ([model.task_status integerValue] == 3) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateApproved),
                @(TaskStateFail),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createFail],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        
        if ([model.task_status integerValue] == 4) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateApproved),
                @(TaskStateApproved),
                @(TaskStateNotStarted),
                @(TaskStateNotStarted),
				@(TaskStateNotStarted),
                ]
            ];
            
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createSuccess],
                [MOProcessView createNormal],
                [MOProcessView createNormal],
				[MOProcessView createNormal],
             ]
            ];
        }
        
        if ([model.task_status integerValue] == 5) {
            [states addObjectsFromArray:
                 @[
                @(TaskStateApproved),
                @(TaskStateApproved),
                @(TaskStateApproved),
                model.is_pay == 0?@(TaskStateInProgress):@(TaskStateApproved),
				model.is_pay == 0?@(TaskStateNotStarted):@(TaskStateApproved),
                ]
            ];
            
            [subTitles addObjectsFromArray:currentTitles];
            [progressBar addObjectsFromArray:
             @[
                [MOProcessView createSuccess],
                [MOProcessView createSuccess],
                model.is_pay == 0?[MOProcessView createInReview]:[MOProcessView createSuccess],
				model.is_pay == 0?[MOProcessView createNormal]:[MOProcessView createSuccess],
             ]
            ];
            
            
        }
    }
    
    
    
    
    for (int i = 0; i < (subTitles.count - 1); i++) {
        
        MOView *lineView = progressBar[i];
        lineView.backgroundColor = ColorEDEEF5;
        [self.processView addSubview:lineView];
        CGFloat x = (2*i + 1)*1.0/(2*subTitles.count);
        CGFloat width = 2 * 1.0/(2*subTitles.count);
        DLog(@"%d",i);
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.processView.mas_right).multipliedBy(x);
            make.height.equalTo(@(5));
            make.width.equalTo(self.mas_width).multipliedBy(width);
            make.centerY.equalTo(self.processView.mas_top).offset(20);
        }];
    }
    
    MOView *lineView = [MOProcessView createNormal];
    [self.processView addSubview:lineView];
    MOView *lastProgressBar = progressBar.lastObject;
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(lastProgressBar.mas_right);
        make.height.equalTo(@(5));
        make.right.equalTo(self.processView.mas_right);
        make.centerY.equalTo(self.processView.mas_top).offset(20);
    }];
    
    
    for (int i = 0; i < subTitles.count; i++) {
        
        NSString *title = StringWithFormat(@"%d",i + 1);
        NSString *subTitle = subTitles[i];
        TaskState state = [states[i] integerValue];
        MOButton *btn = [MOButton new];
        [self.processView addSubview:btn];
        if (state == TaskStateCompletedTestData) {
            
        }
        
        if (state == TaskStateApproved) {
            [btn setImage:[UIImage imageNamedNoCache:@"icon_process_success.png"]];
        }
        if (state == TaskStateFail) {
            [btn setImage:[UIImage imageNamedNoCache:@"icon_process_fail.png"]];
        }
        if (state == TaskStateCompletedTestData) {
            
            [btn setImage:[UIImage imageNamedNoCache:@"icon_process_success.png"]];
        }
        
        
        if (state == TaskStateNotStarted) {
            
            [btn setTitle:title titleColor:ColorAFAFAF bgColor:ColorD9D9D9 font:MOPingFangSCBoldFont(10)];
        }
        
        
        if (state == TaskStateInReview || state == TaskStateInProgress) {
            [btn setTitle:title titleColor:WhiteColor bgColor:ColorFC9E09 font:MOPingFangSCBoldFont(10)];
        }
        
        CGFloat x = (2*i + 1)*1.0/(2*subTitles.count);
        [btn cornerRadius:QYCornerRadiusAll radius:8];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self.processView.mas_top).offset(20);
            make.centerX.equalTo(self.processView.mas_right).multipliedBy(x);
            make.width.height.equalTo(@(16));
        }];
        
        UILabel *label = [UILabel labelWithText:subTitle textColor:Color626262 font:MOPingFangSCMediumFont(10)];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        [self.processView addSubview:label];
        CGFloat width = 2 * 1.0/(2*subTitles.count);
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(btn.mas_centerX);
            make.width.equalTo(self.mas_width).multipliedBy(width);
            make.top.equalTo(btn.mas_bottom).offset(15);
        }];
    }
    
    
}



-(MOView *)markView {
    
    if (!_markView) {
        _markView = [MOView new];
        _markView.backgroundColor = ColorF2F2F2;
    }
    return _markView;
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:BlackColor font:MOPingFangSCHeavyFont(16)];
    }
    return _titleLabel;
}

-(MOView *)processView {
    
    if (!_processView) {
        _processView = [MOView new];
        _processView.backgroundColor = ClearColor;
    }
    return _processView;
    
}

@end


@interface MOProcessView ()
@property(nonatomic,strong)CAGradientLayer *gradientLayer1;
@property(nonatomic,strong)CAGradientLayer *gradientLayer2;
@property(nonatomic,strong)CAGradientLayer *gradientLayer3;
@property(nonatomic,strong)CAGradientLayer *gradientLayer4;
@end
@implementation MOProcessView


+(instancetype)createNormal {
    MOProcessView *vi = [[self class] new];
    [vi showNormal];
    return vi;
}

+(instancetype)createFail {
    MOProcessView *vi = [[self class] new];
    [vi showFail];
    return vi;
}


+(instancetype)createSuccess {
    MOProcessView *vi = [[self class] new];
    [vi showSuccess];
    return vi;
}

+(instancetype)createInReview {
    MOProcessView *vi = [[self class] new];
    [vi showInReview];
    return vi;
}

+(instancetype)createInProcess {
    MOProcessView *vi = [[self class] new];
    [vi showInReview];
    return vi;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.gradientLayer1) {
        
        if (self.gradientLayer1.frame.size.width != self.bounds.size.width ||
            self.gradientLayer1.frame.size.height != self.bounds.size.height) {
            self.gradientLayer1.frame = self.bounds;
        }
    }
    
    if (self.gradientLayer2) {
        
        if (self.gradientLayer2.frame.size.width != self.bounds.size.width ||
            self.gradientLayer2.frame.size.height != self.bounds.size.height) {
            self.gradientLayer2.frame = self.bounds;
        }
    }
    
    
    if (self.gradientLayer3) {
        
        if (self.gradientLayer3.frame.size.width != self.bounds.size.width ||
            self.gradientLayer3.frame.size.height != self.bounds.size.height) {
            self.gradientLayer3.frame = self.bounds;
        }
    }
    if (self.gradientLayer4) {
        
        if (self.gradientLayer4.frame.size.width != self.bounds.size.width ||
            self.gradientLayer4.frame.size.height != self.bounds.size.height) {
            self.gradientLayer4.frame = self.bounds;
        }
    }
}


-(void)addSubViewsInFrame:(CGRect)frame {
    
    self.gradientLayer1.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer1 atIndex:0];
    
    self.gradientLayer2.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer2 atIndex:0];
    
    
    self.gradientLayer3.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer3 atIndex:0];
    
    self.gradientLayer4.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer4 atIndex:0];
}

-(void)showNormal{
    
    self.gradientLayer1.hidden = NO;
    self.gradientLayer2.hidden = YES;
    self.gradientLayer3.hidden = YES;
    self.gradientLayer4.hidden = YES;
}

-(void)showFail{
    
    self.gradientLayer1.hidden = YES;
    self.gradientLayer2.hidden = NO;
    self.gradientLayer3.hidden = YES;
    self.gradientLayer4.hidden = YES;
}

-(void)showSuccess{
    
    self.gradientLayer1.hidden = YES;
    self.gradientLayer2.hidden = YES;
    self.gradientLayer3.hidden = NO;
    self.gradientLayer4.hidden = YES;
}

-(void)showInReview{
    
    self.gradientLayer1.hidden = YES;
    self.gradientLayer2.hidden = YES;
    self.gradientLayer3.hidden = YES;
    self.gradientLayer4.hidden = NO;
}

-(void)showInProcess{
    
    self.gradientLayer1.hidden = YES;
    self.gradientLayer2.hidden = YES;
    self.gradientLayer3.hidden = YES;
    self.gradientLayer4.hidden = NO;
}


- (CAGradientLayer *)gradientLayer1 {
    
    if (!_gradientLayer1) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)ColorEDEEF5.CGColor,(id)ColorEDEEF5.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayer1 = gradientLayer;
    }
    
    return _gradientLayer1;
}

- (CAGradientLayer *)gradientLayer2 {
    
    if (!_gradientLayer2) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)Color34C759.CGColor,(id)ColorFF0000.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayer2 = gradientLayer;
    }
    
    return _gradientLayer2;
}


- (CAGradientLayer *)gradientLayer3 {
    
    if (!_gradientLayer3) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)Color34C759.CGColor,(id)Color34C759.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayer3 = gradientLayer;
    }
    
    return _gradientLayer3;
}

- (CAGradientLayer *)gradientLayer4 {
    
    if (!_gradientLayer4) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1, 1);
        NSMutableArray *gradientColors = @[(id)Color34C759.CGColor,(id)ColorFC9E09.CGColor].mutableCopy;
        gradientLayer.colors = gradientColors;
        _gradientLayer4 = gradientLayer;
    }
    
    return _gradientLayer4;
}


@end
