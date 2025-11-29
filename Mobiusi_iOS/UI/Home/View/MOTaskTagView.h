//
//  MOTaskTagView.h
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/14.
//

#import "MOView.h"
#import "MOTaskListModel.h"
#import "MOTaskDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOTaskTagView : MOView

- (void)configWithTagArray:(NSArray<MOTaskListTagModel *> *)tagArray;

- (void)configWithDetailTagArray:(NSArray<MOTaskDetailTag *> *)tagArray;

@end

NS_ASSUME_NONNULL_END
