//
//  MOTableViewController.m
//  YuYun
//
//  Created by x11 on 2023/8/16.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import "MOTableViewController.h"
@interface MOTableViewController () <UIScrollViewDelegate> {
    CGFloat _contentOffsetY;
    
    BOOL _scrollToTopValid;
    BOOL _scrollToBottomValid;
}

@end

@implementation MOTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _scrollToTopValid = YES;
    _scrollToBottomValid = YES;
    _respondScrollDelegate = YES;
    
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)addTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    return tableView;
}

- (void)scrollViewRespondScrollDelegate:(BOOL)respond {
    _respondScrollDelegate = respond;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _contentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_respondScrollDelegate == YES) {
        if (scrollView.contentOffset.y <= 0) {
            if (_scrollToTopValid == YES) {
                _scrollToTopValid = NO;
                if (self.didScrollToTop) {
                    self.didScrollToTop(scrollView.contentOffset.y);
                }
            }
        } else {
            _scrollToTopValid = YES;
        }
        
        CGFloat offset = scrollView.contentSize.height - scrollView.bounds.size.height;
        if (scrollView.contentOffset.y >= offset) {
            if (_scrollToBottomValid == YES) {
                _scrollToBottomValid = NO;
                if (self.didScrollToBottom) {
                    self.didScrollToBottom(scrollView.contentOffset.y);
                }
            }
        } else {
            _scrollToBottomValid = YES;
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ((scrollView.contentOffset.y - _contentOffsetY) > 5.0f) {  // 向上拖拽
        if (self.dragDirection) {
            self.dragDirection(MTDragDirectionUp);
        }
    } else if ((scrollView.contentOffset.y - _contentOffsetY) < -5.0f) {   // 向下拖拽
        if (self.dragDirection) {
            self.dragDirection(MTDragDirectionDown);
        }
    } else {
        
    }
}

#pragma mark - getter setter

-(UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [self addTableView];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 60;
        if (@available(iOS 11.0, *)){
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
        _tableView.tableFooterView = ({
            UIView *footView = [UIView new];
            footView;
        });
    }
    return _tableView;
}
@end
