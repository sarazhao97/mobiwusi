//
//  MOMyVoiceScheduleCell.h
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/3.
//

#import "MOBaseScheduleCell.h"
#import "MODocFileItemView.h"
#import "MOVoicePlayView.h"
#import "MOUserTaskDataModel.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MOMyVoiceScheduleCellDelegate <NSObject>

- (void)audioPlayerCell:(UITableViewCell *)cell didUpdateProgress:(float)progress currentTime:(NSTimeInterval)currentTime;
- (void)audioPlayerCell:(UITableViewCell *)cell didChangeState:(NSString *)state;
- (void)audioPlayerCellDidRequestPlay:(UITableViewCell *)cell; // 请求播放

@end

@interface MOMyVoiceScheduleCell : MOBaseScheduleCell
@property(nonatomic,strong)YYLabel *dataTitle;
@property(nonatomic,strong)MOView *attachmentFilesView;
@property(nonatomic,strong)UILabel *paramLabel;
@property (nonatomic, weak) id<MOMyVoiceScheduleCellDelegate> delegate;

- (void)configCellData:(MOUserTaskDataModel *)data;
- (void)play;
- (void)pause;
- (void)stop;
- (void)updatePlayingState:(BOOL)isPlaying; // 更新播放状态
- (void)startPlaying;

@end

NS_ASSUME_NONNULL_END
