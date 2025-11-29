//
//  MOTaskTagView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/14.
//

#import "MOTaskTagView.h"

@interface MOTaskTagView ()

@end

@implementation MOTaskTagView

- (void)addSubViewsInFrame:(CGRect)frame {
    
}

- (void)removeAllSubviews {
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
}

- (void)configWithTagArray:(NSArray<MOTaskListTagModel *> *)tagArray {
    [self removeAllSubviews];
    CGFloat totalWidth = 0;
    CGFloat maxWidth = SCREEN_WIDTH-20-40;
    for (NSInteger i = 0; i < tagArray.count; i++) {
        MOTaskListTagModel *model = tagArray[i];
        NSString *tag = model.name;
        CGSize size = [Util calculateLabelSizeWithText:tag andMarginSize:CGSizeMake(CGFLOAT_MAX, 18) andTextFont:[UIFont systemFontOfSize:12]];
        if (totalWidth + size.width+20 > maxWidth) {
            return;
        }
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(totalWidth, 0, size.width+10, 18)];
        view.layer.cornerRadius = 3.f;
        [self addSubview:view];
        UILabel *label = [UILabel new];
        label.text = tag;
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
        }];
        
        if (model.enable == 1) {
            view.backgroundColor = [UIColor colorWithHexString:@"#FDE7E7"];
            label.textColor = [UIColor colorWithHexString:@"#FF0047"];
        } else {
            view.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
            label.textColor = [UIColor colorWithHexString:@"#D2D2D2"];
        }
        totalWidth += 10+size.width+5;
    }
}

- (void)configWithDetailTagArray:(NSArray<MOTaskDetailTag *> *)tagArray {
    [self removeAllSubviews];
    CGFloat totalWidth = 0;
    CGFloat maxWidth = SCREEN_WIDTH-20-40;
    for (NSInteger i = 0; i < tagArray.count; i++) {
        MOTaskDetailTag *model = tagArray[i];
        NSString *tag = model.name;
        CGSize size = [Util calculateLabelSizeWithText:tag andMarginSize:CGSizeMake(CGFLOAT_MAX, 18) andTextFont:[UIFont systemFontOfSize:12]];
        if (totalWidth + size.width+20 > maxWidth) {
            return;
        }
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(totalWidth, 0, size.width+10, 18)];
        view.layer.cornerRadius = 3.f;
        [self addSubview:view];
        UILabel *label = [UILabel new];
        label.text = tag;
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
        }];
        
        if (model.enable == 1) {
            view.backgroundColor = [UIColor colorWithHexString:@"#FDE7E7"];
            label.textColor = [UIColor colorWithHexString:@"#FF0047"];
        } else {
            view.backgroundColor = [UIColor colorWithHexString:@"#F4F4F4"];
            label.textColor = [UIColor colorWithHexString:@"#D2D2D2"];
        }
        totalWidth += 10+size.width+5;
    }
}


@end
