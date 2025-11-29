//
//  MOApplyCashVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/5.
//

#import "MOApplyCashVC.h"
#import "MOCateOptionModel.h"
#import "MOCashAmountCell.h"
#import "NSObject+KVO.h"
#import "MOWithdrawalRecordVC.h"

@interface MOApplyCashVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
// 可提现金额区域
@property (weak, nonatomic) IBOutlet UIView *cashAmountView;
@property(nonatomic,strong)MOCateOptionModel *cateOptionModel;

@property (weak, nonatomic) IBOutlet UILabel *account_balanceLabel;

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,assign)NSInteger currentSelectedIndex;
@property (weak, nonatomic) IBOutlet UILabel *withdrawalAmountTitleLabel;


@property (weak, nonatomic) IBOutlet UITextField *recipientNameTF;

@property (weak, nonatomic) IBOutlet UITextField *openingBankNameTF;
@property (weak, nonatomic) IBOutlet UITextField *bankCardNumberTF;

@property (weak, nonatomic) IBOutlet MOButton *backBtnClick;
@property (weak, nonatomic) IBOutlet MOButton *withdrawalRecordBtn;

@end

@implementation MOApplyCashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.account_balanceLabel.text = self.account_balance;
    [self.backBtnClick setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
//    [self.withdrawalRecordBtn setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
//    [self.withdrawalRecordBtn setTitle:@"提现记录" titleColor:Color002FA8 bgColor:ClearColor font:MOPingFangSCBoldFont(13)];
    self.withdrawalRecordBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.withdrawalRecordBtn.titleLabel.minimumScaleFactor = 0.6;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MOCashAmountCell class] forCellWithReuseIdentifier:@"MOCashAmountCell"];
    WEAKSELF
    [self.collectionView observeValueForKeyPath:@"contentSize" chnageBlck:^(NSDictionary * _Nonnull change, id  _Nonnull object) {
        
        CGSize size = [change[@"new"] CGSizeValue];
        if (weakSelf.collectionView.frame.size.width != size.width || weakSelf.collectionView.frame.size.height != size.height) {
            [weakSelf.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(size.height));
            }];
            [weakSelf.cashAmountView setNeedsLayout];
            [weakSelf.cashAmountView layoutIfNeeded];
        }
        DLog(@"%@",change);
    }];
    [self.cashAmountView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.top.equalTo(self.cashAmountView.mas_top);
        make.bottom.equalTo(self.cashAmountView.mas_bottom);
        make.left.equalTo(self.cashAmountView.mas_left).offset(16.5);
        make.right.equalTo(self.cashAmountView.mas_right).offset(-16.5);
        make.height.equalTo(@(10));
    }];
    
    [self loadRequest];
}

-(void)loadRequest {
    
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] getCateOptionSuccess:^(NSDictionary *dic) {
        [self hidenActivityIndicator];
        self.cateOptionModel = [MOCateOptionModel yy_modelWithJSON:dic];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        [self showActivityIndicator];
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self showActivityIndicator];
        [self showErrorMessage:string];
    } loginFail:^{
        [self hidenActivityIndicator];
    }];
}

- (IBAction)applyBtnClick:(id)sender {
    
    
    MOCateOptionItem *model = self.cateOptionModel.withdrawal_money[self.currentSelectedIndex];
    if ([self.account_balance floatValue] < [model.value floatValue]) {
        
        [self showMessage:NSLocalizedString(@"余额不足", nil)];
        return;
    }
    
    if (!self.recipientNameTF.text.length) {
        [self showMessage:NSLocalizedString(@"请填写银行卡卡号", nil)];
        return;
    }
    
    if (!self.openingBankNameTF.text.length) {
        [self showMessage:NSLocalizedString(@"请填写开户行", nil)];
        return;
    }
    if (!self.bankCardNumberTF.text.length) {
        [self showMessage:NSLocalizedString(@"请填写银行卡卡号", nil)];
        return;
    }
    
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] userWithdrawalSaveWithMoney:model.value bank_user_name:self.recipientNameTF.text bank_name:self.openingBankNameTF.text bank_no:self.bankCardNumberTF.text type:0 transferChannel:3 success:^(NSDictionary *dic) {
        [self hidenActivityIndicator];
        [MOAppDelegate.transition popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
        [self hidenActivityIndicator];
        [self showErrorMessage:error.localizedDescription];
    } msg:^(NSString *string) {
        [self hidenActivityIndicator];
        [self showErrorMessage:string];
    } loginFail:^{
        [self hidenActivityIndicator];
    }];
    
}
- (IBAction)backBtnClick:(id)sender {
    
    [MOAppDelegate.transition popViewControllerAnimated:YES];
}
- (IBAction)withdrawalRecordBtnClick:(id)sender {
    
    MOWithdrawalRecordVC *vc = [MOWithdrawalRecordVC new];
    [MOAppDelegate.transition pushViewController:vc animated:YES];
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.cateOptionModel.withdrawal_money.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MOCashAmountCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOCashAmountCell" forIndexPath:indexPath];
    MOCateOptionItem *model = self.cateOptionModel.withdrawal_money[indexPath.item];
    if (self.currentSelectedIndex == indexPath.row) {
        [cell configSelectedSateCellWithModel:model];
    } else {
        [cell configNormalSateCellWithModel:model];
    }
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.currentSelectedIndex) {
        return;
    }
    self.currentSelectedIndex = indexPath.item;
    [collectionView reloadData];
    
}

#pragma mark - setter && getter
-(UICollectionView *)collectionView {
    
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowfy = [UICollectionViewFlowLayout new];
        flowfy.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowfy.minimumLineSpacing = 10;
        flowfy.minimumInteritemSpacing = 11;
        CGFloat leftMargin = 16.5;
        CGFloat parentLeftMargin = 10;
        CGFloat width = (SCREEN_WIDTH - 2*leftMargin - 2*11 - parentLeftMargin *2)/3.0 -0.5;
        CGFloat higeht = 70 *width/113.0;
        flowfy.itemSize = CGSizeMake(width, higeht);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowfy];
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = ClearColor;
    }
    return _collectionView;
}

@end
