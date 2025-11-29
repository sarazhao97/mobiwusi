//
//  MOTextFillTaskStep2View.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOView.h"
#import "MOTaskListModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MOTextFillTaskStep2View : MOView<UICollectionViewDelegate,UICollectionViewDataSource,UIDocumentPickerDelegate>
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)MOButton *exampleBtn;
@property(nonatomic,strong)UITextView *textInput;
@property(nonatomic,strong)UICollectionView *attchmentCollectionView;
@property(nonatomic,copy)void(^didExampleBtnClick)(void);
-(void)configUIWithModel:(MOTaskListModel *)model;
@end

NS_ASSUME_NONNULL_END
