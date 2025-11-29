//
//  MOFeedbackViewController.m
//  Mobiusi_iOS
//
//  Created by x11 on 2025/3/11.
//

#import "MOFeedbackViewController.h"
#import "UITextView+ZWPlaceHolder.h"
#import <TZImagePickerController.h>

@interface MOFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UITextView *detailTv;
@property (weak, nonatomic) IBOutlet UITextField *contactTf;
@property (weak, nonatomic) IBOutlet UIImageView *addImage;
@property (nonatomic, strong) UIImage *selectImage;

@end

@implementation MOFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.detailTv.zw_placeHolder = NSLocalizedString(@"请在此输入详细问题或意见", nil);
    self.detailTv.zw_placeHolderColor = [BlackColor colorWithAlphaComponent:0.15];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)submitClick:(id)sender {
    if (self.detailTv.text.isExist == NO) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请先输入详细问题或意见！", nil) toView:MOAppDelegate.window];
        return;
    }
    
    if (self.contactTf.text.isExist == NO) {
        [MBProgressHUD showMessag:NSLocalizedString(@"请先输入您的联系方式", nil) toView:MOAppDelegate.window];
        return;
    }
    
    NSString *feedback_content = self.detailTv.text;
    NSString *feedback_contact = self.contactTf.text;
    if (self.selectImage) {
        MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];

        [[MONetDataServer sharedMONetDataServer] uploadImage:self.selectImage success:^(NSDictionary *dic) {
            NSString *relateUrl = dic[@"relative_url"];

            [[MONetDataServer sharedMONetDataServer] feedbackWithType:0 content:feedback_content contact_info:feedback_contact detail_img:relateUrl success:^(NSDictionary *dic) {
                [hud hide:YES];
                [MBProgressHUD showSuccess:NSLocalizedString(@"感谢您的反馈！", nil) toView:MOAppDelegate.window];
                [self goBack];
            } failure:^(NSError *error) {
                [hud hide:YES];
                [MBProgressHUD showError:error.localizedDescription toView:MOAppDelegate.window];

            } msg:^(NSString *string) {
                [hud hide:YES];
                [MBProgressHUD showError:string toView:MOAppDelegate.window];

            } loginFail:^{
                [hud hide:YES];

            }];
            
        } failure:^(NSError *error) {
            [hud hide:YES];
            [MBProgressHUD showError:NSLocalizedString(@"上传头像失败", nil) toView:MOAppDelegate.window];
            
        } loginFail:^{
            [hud hide:YES];
        }];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
        [[MONetDataServer sharedMONetDataServer] feedbackWithType:0 content:feedback_content contact_info:feedback_contact detail_img:@"" success:^(NSDictionary *dic) {
            [hud hide:YES];
            [MBProgressHUD showSuccess:NSLocalizedString(@"感谢您的反馈！", nil) toView:MOAppDelegate.window];
            [self goBack];
        } failure:^(NSError *error) {
            [hud hide:YES];
            [MBProgressHUD showError:error.localizedDescription toView:MOAppDelegate.window];

        } msg:^(NSString *string) {
            [hud hide:YES];
            [MBProgressHUD showError:string toView:MOAppDelegate.window];

        } loginFail:^{
            [hud hide:YES];

        }];
    }

}

- (IBAction)addImageClick:(id)sender {
    [self goPickeImages];
}

- (IBAction)backClick:(id)sender {
    [self goBack];
}

- (void)goPickeImages {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingVideo = NO;
    NSMutableArray *imageAssets = @[].mutableCopy;
    imagePickerVc.selectedAssets = imageAssets;
    imagePickerVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePickerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *selectImage = photos[0];
            self.addImage.image = selectImage;
            self.selectImage = selectImage;
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}



@end
