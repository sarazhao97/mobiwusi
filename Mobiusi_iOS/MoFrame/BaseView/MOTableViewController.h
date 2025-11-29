//
//  MOTableViewController.h
//  YuYun
//
//  Created by x11 on 2023/8/16.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import "MOBaseViewController.h"

typedef enum : NSUInteger {
    MTDragDirectionUp,
    MTDragDirectionDown
} MTDragDirection;

@interface MOTableViewController : MOBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    BOOL _respondScrollDelegate;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) void (^dragDirection)(MTDragDirection direction);

@property (nonatomic, copy) void (^didScrollToTop)(CGFloat contentOffsetY);
@property (nonatomic, copy) void (^didScrollToBottom)(CGFloat contentOffsetY);

- (UITableView *)addTableView;

- (void)scrollViewRespondScrollDelegate:(BOOL)respond;

@end
