//
//  MOFillTaskTopicTitleView.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/21.
//

#import "MOView.h"
#import "MOTaskListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOFillTaskTopicTitleView : MOView
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOView *leftContentView;
@property(nonatomic,strong)UILabel *tagLabel;
@property(nonatomic,strong)UILabel *indexLabel;
@property(nonatomic,strong)UILabel *tidLabel;
-(void)configNoTidViewWithModel:(MOTaskListModel *)model withIndex:(NSInteger)index;
-(void)configViewWithModel:(MOTaskListModel *)model withIndex:(NSInteger)index total:(NSInteger)total;
@end

NS_ASSUME_NONNULL_END
