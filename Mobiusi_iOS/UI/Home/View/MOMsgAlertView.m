//
//  MOMsgAlertView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/4.
//

#import "MOMsgAlertView.h"

@interface MOMsgAlertView ()

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@property (nonatomic, copy) MOBlock sureClickHandle;

@end

@implementation MOMsgAlertView

+ (void)showWithTitle:(NSString *)title andMsg:(NSString *)msg andSureClickHandle:(MOBlock)sure {
    
    MOMsgAlertView *view = [[[NSBundle mainBundle]loadNibNamed:@"MOMsgAlertView" owner:nil options:nil] lastObject];
    view.title.text = title;
    view.msgLabel.text = msg;
    view.sureClickHandle = sure;
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [MOAppDelegate.window addSubview:view];
}

+ (void)showWithTitle:(NSString *)title andMsg:(NSString *)msg cancelTitle:(NSString *)cancelTitle sureTitle:(NSString *)sureTitle andSureClickHandle:(MOBlock)sure {
    
    MOMsgAlertView *view = [[[NSBundle mainBundle]loadNibNamed:@"MOMsgAlertView" owner:nil options:nil] lastObject];
    view.title.text = title;
    view.msgLabel.text = msg;
    [view.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    [view.sureButton setTitle:sureTitle forState:UIControlStateNormal];
    view.sureClickHandle = sure;
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [MOAppDelegate.window addSubview:view];
}


- (IBAction)sureClick:(id)sender {
    if (self.sureClickHandle) {
        self.sureClickHandle();
    }
    [self removeFromSuperview];
}

- (IBAction)cancelClick:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)closeClick:(id)sender {
    [self removeFromSuperview];
}

@end
