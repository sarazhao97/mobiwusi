//
//  MOUserAssetDatePickerVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/10.
//

#import "MOUserAssetDatePickerVC.h"

@interface MOUserAssetDatePickerVC ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,strong)MOView *contentView;
@property(nonatomic,strong)UIPickerView *datePickerView;
@property (nonatomic, strong) NSArray<NSString *> *years;
@property (nonatomic, strong) NSArray<NSString *> *months;
@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger currentMonth;
@property(nonatomic,strong)MOView *bottomView;
@property(nonatomic,strong)MOView *lineView;
@property(nonatomic,strong)MOButton *cancelButton;
@property(nonatomic,strong)MOButton *confirmButton;

@end

@implementation MOUserAssetDatePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor =ClearColor;
    
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = [BlackColor colorWithAlphaComponent:0.1];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView addSubview:self.bottomView];
    self.bottomView.backgroundColor = WhiteColor;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        
    }];
    
    [self.bottomView addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(hiddenAnimate) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.height.equalTo(@(45));
//        make.width.equalTo(@(55));
    }];
    
    [self.bottomView addSubview:self.confirmButton];
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.bottomView.mas_top);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.height.equalTo(@(45));
//        make.width.equalTo(@(55));
    }];
    
    [self.bottomView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.confirmButton.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.equalTo(@(1));
    }];
    
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    self.currentYear = [calendar component:NSCalendarUnitYear fromDate:now];
    self.currentMonth = [calendar component:NSCalendarUnitMonth fromDate:now];
    NSMutableArray *years = [NSMutableArray array];
    for (int i = 0; i < self.currentYear - 2024; i++) {
        [years addObject:[NSString stringWithFormat:@"%ld", (long)(self.currentYear - i)]];
    }
    self.years = [years reverseObjectEnumerator].allObjects; // 降序显示
    [self updateMonthsForYear:self.currentYear];
    
    [self.bottomView addSubview:self.datePickerView];
    self.datePickerView.dataSource = self;
    self.datePickerView.delegate = self;
    [self.datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.lineView.mas_bottom);
        make.left.equalTo(self.bottomView.mas_left);
        make.right.equalTo(self.bottomView.mas_right);
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(Bottom_SafeHeight>0?-Bottom_SafeHeight:-20);
        
    }];
    
}


-(void)showAnimate {
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        
    }];
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

-(void)hiddenAnimate {
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
        make.top.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        
    }];
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [self dismissViewControllerAnimated:NO completion:NULL];
    }];
}

-(void)confirmButtonClick {
    
    [self hiddenAnimate];
    NSString *selectedYear = self.years[[self.datePickerView selectedRowInComponent:0]];
    NSString *selectedMonth = self.months[[self.datePickerView selectedRowInComponent:1]];
    NSString *dateString = [NSString stringWithFormat:@"%@-%@", selectedYear, selectedMonth];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM";
    NSDate *date =  [dateFormatter dateFromString:dateString];
    NSString *chinaDateStr = [NSString stringWithFormat:NSLocalizedString(@"%@年%@月", nil), selectedYear, selectedMonth];;
    if (self.didConfirmButtonClick) {
        self.didConfirmButtonClick(dateString,chinaDateStr,date);
    }
}


- (void)updateMonthsForYear:(NSInteger)year {
    NSMutableArray *months = [NSMutableArray array];
    if (year == self.currentYear) {
        // 当前年份，显示到当前月份
        for (int i = 1; i <= self.currentMonth; i++) {
            [months addObject:[NSString stringWithFormat:@"%02d", i]];
        }
        
    } else {
        // 非当前年份，显示 1 - 12 月
        for (int i = 1; i <= 12; i++) {
            [months addObject:[NSString stringWithFormat:@"%02d", i]];
        }
    }
    self.months = [months reverseObjectEnumerator].allObjects;
    [self.datePickerView reloadComponent:1];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return component == 0 ? self.years.count : self.months.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return component == 0 ? self.years[row] : self.months[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // 获取选中的年月并处理
    if (component == 0) {
            // 选中年份改变，更新月份数据
            NSString *selectedYearString = self.years[row];
            NSInteger selectedYear = [selectedYearString integerValue];
            [self updateMonthsForYear:selectedYear];
    }
    NSString *selectedYear = self.years[[pickerView selectedRowInComponent:0]];
    NSString *selectedMonth = self.months[[pickerView selectedRowInComponent:1]];
    NSString *dateString = [NSString stringWithFormat:@"%@-%@", selectedYear, selectedMonth];
    DLog(@"选中的日期：%@", dateString);
}


#pragma mark - setter && getter
-(MOView *)contentView {
    
    if (!_contentView) {
        _contentView = [MOView new];
        
    }
    return _contentView;
}

-(MOView *)bottomView {
    
    if (!_bottomView) {
        _bottomView = [MOView new];
    }
    return _bottomView;
}

-(MOButton *)cancelButton {
    
    if (!_cancelButton) {
        _cancelButton = [MOButton new];
        [_cancelButton setTitle:NSLocalizedString(@"取消", nil) titleColor:MainSelectColor bgColor:ClearColor font:MOPingFangSCMediumFont(15)];
        [_cancelButton setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _cancelButton;
}

-(MOButton *)confirmButton {
    
    if (!_confirmButton) {
        _confirmButton = [MOButton new];
        [_confirmButton setTitle:NSLocalizedString(@"确定", nil) titleColor:MainSelectColor bgColor:ClearColor font:MOPingFangSCMediumFont(15)];
        [_confirmButton setEnlargeEdgeWithTop:10 left:10 bottom:10 right:10];
    }
    return _confirmButton;
}
-(MOView *)lineView {
    
    if (!_lineView) {
        _lineView = [MOView new];
        _lineView.backgroundColor = [Color9B9B9B colorWithAlphaComponent:0.3];
    }
    return _lineView;
}

-(UIPickerView *)datePickerView {
    
    if (!_datePickerView) {
        _datePickerView = [[UIPickerView alloc] init];
    }
    
    return _datePickerView;
}


@end
