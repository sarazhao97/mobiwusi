//
//  MOMyTextScheduleCell.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOBaseScheduleCell.h"
#import "MOView.h"
#import "MODocFileItemView.h"
#import "MOUserTaskDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOMyTextScheduleCell : MOBaseScheduleCell
@property(nonatomic,copy)void(^didClickFile)(NSInteger index);
@property(nonatomic,strong)YYLabel *dataTitle;
@property(nonatomic,strong)MOView *attachmentFilesView;
-(void)configCellData:(MOUserTaskDataModel *)data;
@end

NS_ASSUME_NONNULL_END
