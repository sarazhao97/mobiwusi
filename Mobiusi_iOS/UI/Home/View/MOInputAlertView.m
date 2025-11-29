//
//  MOInputAlertView.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/4.
//

#import "MOInputAlertView.h"

@interface MOInputAlertView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (nonatomic, copy) MOStringBlock sureClickHandle;
@property (nonatomic, assign) NSInteger maxCount;
@end

@implementation MOInputAlertView

+ (void)showWithTitle:(NSString *)title andMsg:(NSString *)msg andPlaceHolder:(NSString *)placeHolder andMaxCount:(NSInteger)maxCount andSureClickHandle:(MOStringBlock)sure {

    MOInputAlertView *view = [[[NSBundle mainBundle]loadNibNamed:@"MOInputAlertView" owner:nil options:nil] lastObject];
    view.textFiled.delegate = view;
    view.titleLabel.text = title;
    view.textFiled.placeholder = placeHolder;
    view.textFiled.text = msg;
    view.sureClickHandle = sure;
    view.maxCount = maxCount;
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [MOAppDelegate.window addSubview:view];
}

- (IBAction)cancelClick:(id)sender {
    if (self.textFiled.isFirstResponder) {
        [self.textFiled resignFirstResponder];
    }
    [self removeFromSuperview];
}

- (IBAction)sureClick:(id)sender {
    if (self.sureClickHandle) {
        self.sureClickHandle(self.textFiled.text);
    }
    if (self.textFiled.isFirstResponder) {
        [self.textFiled resignFirstResponder];
    }
    [self removeFromSuperview];
}

- (IBAction)closeClick:(id)sender {
    if (self.textFiled.isFirstResponder) {
        [self.textFiled resignFirstResponder];
    }
    [self removeFromSuperview];
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *text = textField.text;
    if (self.maxCount > 0 && text.length > self.maxCount) {
        textField.text = [text substringToIndex:self.maxCount];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
