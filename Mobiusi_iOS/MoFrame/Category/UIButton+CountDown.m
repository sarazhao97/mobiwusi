//
//  UIButton+CountDown.m
//  TKFamilyTrust
//
//  Created by zhangxiaoliang01 on 2021/3/24.
//

#import "UIButton+CountDown.h"
#import <objc/message.h>
@interface UIButton (CountDown)
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,copy)NSString *(^intervalCallBack)(UIButton *btn,NSInteger count);
@property(nonatomic,assign)NSInteger countIndex;
@end

static const char *timerKey = "timer";
static const char *intervalCallBackKey = "intervalCallBack";
static const char *countIndexKey = "countIndex";

@implementation UIButton (CountDown)

-(void)setTimer:(NSTimer *)timer {
    
    objc_setAssociatedObject(self, &timerKey, timer, OBJC_ASSOCIATION_RETAIN);
}

-(NSTimer *)timer {
    
    return  objc_getAssociatedObject(self, &timerKey);
}

-(void)setIntervalCallBack:(NSString *(^)(UIButton *, NSInteger))intervalCallBack {
    
    objc_setAssociatedObject(self, &intervalCallBackKey, intervalCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *(^)(UIButton *, NSInteger))intervalCallBack {
    
    
    return  objc_getAssociatedObject(self, &intervalCallBackKey);
}

-(void)setCountIndex:(NSInteger)countIndex {
    
    objc_setAssociatedObject(self, &countIndexKey, @(countIndex), OBJC_ASSOCIATION_RETAIN);
}

-(NSInteger)countIndex {
    
    NSNumber *countIndex =  objc_getAssociatedObject(self, &countIndexKey);
    return  [countIndex integerValue];
}

-(void)startCountDownWithTitle:(NSString *(^)(UIButton *btn,NSInteger count))intervalCallBack {
    
    if(intervalCallBack) {
        self.intervalCallBack = intervalCallBack;
    }
    
    if (self.timer) {
        [self.timer invalidate];
    }
    
    __weak typeof(self) weakSelf;
//    self.timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//
//
//
//    }];
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timeExecCallBack) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];

}

-(void)timeExecCallBack {
    
    self.countIndex ++;
    NSString *title = self.intervalCallBack(self,self.countIndex);
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
}

-(void)stopCountDown{
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.countIndex = 0;
}


@end
