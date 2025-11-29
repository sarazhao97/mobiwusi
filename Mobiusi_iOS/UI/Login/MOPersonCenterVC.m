//
//  MOPersonCenterVC.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/3.
//

#import "MOPersonCenterVC.h"
#import "MOMsgAlertView.h"
#import "MOInputAlertView.h"
#import "MOMessageListVC.h"
#import "MOWebViewController.h"
#import <TZImagePickerController.h>
#import "MOCheckVersionModel.h"

@interface MOPersonCenterVC ()

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userStorageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usedStorageViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCacheLabel;
/// 0 拍照； 1选择照片
@property (nonatomic, assign) NSInteger selectImageType;

@end

@implementation MOPersonCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectImageType = 0;
    
    MOUserModel *userModel = [MOUserModel unarchiveUserModel];
    [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:userModel.avatar] placeholderImage:[UIImage imageNamedNoCache:@"icon_user_avatar"]];
    self.userNickName.text = userModel.name.isExist?userModel.name:userModel.mobile;
    self.userIdLabel.text = [NSString stringWithFormat:@"%@", userModel.moid];
    self.versionLabel.text = [NSString stringWithFormat:@"V%@", [AppToken getAppVersion]];
    self.userStorageLabel.text = [NSString stringWithFormat:@"%@/%@", userModel.zone_size_used_txt, userModel.zone_size_total_txt];
    self.usedStorageViewWidth.constant = (1.f*userModel.zone_size_used/userModel.zone_size_total)*(SCREEN_WIDTH-20-32-25);
    
    [self calculateCacheSizeWithCompletion:^(NSString *sizeString) {
        self.userCacheLabel.text = sizeString;
    }];
    
}

- (IBAction)clickHandle:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIView *view = tap.view;
    NSInteger index = view.tag-1000;
    
    DLog(@"点击了 - %ld", (long)view.tag);
    
    switch (index) {
        case 0:
        {
            // 设置头像
            [self showUploadAvatarSheet];
        }
            break;
        case 1:
        {
            MOUserModel *userModel = [MOUserModel unarchiveUserModel];

            // 设置昵称
            [MOInputAlertView showWithTitle:NSLocalizedString(@"修改昵称", nil) andMsg:userModel.name andPlaceHolder:NSLocalizedString(@"请输入昵称（不超过8个字）", nil) andMaxCount:8 andSureClickHandle:^(NSString *nickName) {
                MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
                [[MONetDataServer sharedMONetDataServer] modifyUserInfoWithUserName:nickName avatar:@"" sex:0 mobile:@"" describe:@"" native_city:@"" native_city_code:@"" native_province:@"" native_province_code:@"" success:^(NSDictionary *dic) {
                    [hud hide:YES];
                    [MBProgressHUD showMessag:NSLocalizedString(@"修改成功", nil) toView:MOAppDelegate.window];
                    self.userNickName.text = nickName;
                    userModel.name = nickName;
                    [userModel archivedUserModel];
                } failure:^(NSError *error) {
                    [hud hide:YES];
                    [MBProgressHUD showError:NSLocalizedString(@"修改失败", nil) toView:MOAppDelegate.window];
                } msg:^(NSString *string) {
                    [hud hide:YES];
                    [MBProgressHUD showError:string toView:MOAppDelegate.window];
                } loginFail:^{
                    [hud hide:YES];
                }];
            }];
            
        }
            break;
        case 4:
        {
            // 消息通知
            DLog(@"消息通知");
			MOMessageListVC *vc = [[MOMessageListVC alloc] initWithDataId:0 dataCate:0 userTaskResultId:0];
            [MOAppDelegate.transition pushViewController:vc animated:YES];
        }
            break;
        case 6:
        {
            // 意见反馈
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOFeedbackViewController"];
            [MOAppDelegate.transition pushViewController:targetVC animated:YES];
        }
            break;
        case 7:
        {
            // 用户协议
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
            MOWebViewController *webviewController = (MOWebViewController *)targetVC;
            webviewController.webTitle = NSLocalizedString(@"用户协议", nil);
            webviewController.webTitleLabel.text = NSLocalizedString(@"用户协议", nil);
            webviewController.url = service_agreements;
            [MOAppDelegate.transition pushViewController:targetVC animated:YES];
        }
            break;
        case 8:
        {
            // 隐私政策
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *targetVC = [storyBoard instantiateViewControllerWithIdentifier:@"MOWebViewController"];
            MOWebViewController *webviewController = (MOWebViewController *)targetVC;
            webviewController.webTitle = NSLocalizedString(@"隐私政策", nil);
            webviewController.webTitleLabel.text = NSLocalizedString(@"隐私政策", nil);
            webviewController.url = privacy_agreements;
            [MOAppDelegate.transition pushViewController:targetVC animated:YES];
        }
            break;
        case 9:
        {
            // 检查更新
            [self checkVersion];
        }
            break;
        case 10:
        {
            // 清理缓存
            [MOMsgAlertView showWithTitle:NSLocalizedString(@"温馨提示", nil) andMsg:NSLocalizedString(@"确定要清理缓存吗？", nil) andSureClickHandle:^{
                [self clearCacheWithCompletion:^{
                    DLog(@"缓存已清理完成");
                    [MBProgressHUD showSuccess:NSLocalizedString(@"缓存已清理完成", nil) toView:MOAppDelegate.window];
                    [self calculateCacheSizeWithCompletion:^(NSString *sizeString) {
                        self.userCacheLabel.text = sizeString;
                    }];
                }];
            }];
        }
            break;
        case 11:
        {
            // 备案号
        }
            break;
        default:
            break;
    }
}

- (IBAction)backClick:(id)sender {
    [self goBack];
}

- (IBAction)logoutClickHandle:(id)sender {
    [MOMsgAlertView showWithTitle:NSLocalizedString(@"温馨提示", nil) andMsg:NSLocalizedString(@"确定要退出登录吗？", nil) andSureClickHandle:^{
        [MOUserModel removeUserModel];
        [MOAppDelegate.transition popToRootViewControllerAnimated:YES];
    }];

}
- (IBAction)deleteUserClick:(id)sender {
    [MOMsgAlertView showWithTitle:NSLocalizedString(@"注销用户", nil) andMsg:NSLocalizedString(@"请确认您的账户下是否有未完成的任务，待领取待提现的收益等，操作完成后可注销用户。", nil) cancelTitle:NSLocalizedString(@"我再想想", nil) sureTitle:NSLocalizedString(@"确认注销", nil) andSureClickHandle:^{
        [MOMsgAlertView showWithTitle:NSLocalizedString(@"再次确认注销账户", nil) andMsg:NSLocalizedString(@"提交账户注销申请60天内，你仍可登录该账户(登录成功将终止注销流程，但你可重新申请注销):若超过60天未登录，你的账户将被注销且不可恢复，请谨慎操作。", nil) cancelTitle:NSLocalizedString(@"再想想", nil) sureTitle:NSLocalizedString(@"确认注销", nil) andSureClickHandle:^{
            MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];
            [[MONetDataServer sharedMONetDataServer] deleteUserSuccess:^(NSDictionary *dic) {
                [hud hide:YES];
                [MBProgressHUD showSuccess:NSLocalizedString(@"账号已注销", nil) toView:MOAppDelegate.window];
                [MOUserModel removeUserModel];
                [MOAppDelegate.transition popToRootViewControllerAnimated:YES];                        } failure:^(NSError *error) {
                    [hud hide:YES];
                    [MBProgressHUD showMessag:error.localizedDescription toView:MOAppDelegate.window];
                    
                } msg:^(NSString *string) {
                    [hud hide:YES];
                    [MBProgressHUD showMessag:string toView:MOAppDelegate.window];
                } loginFail:^{
                    [hud hide:YES];
                }];
        }];
    }];
}

-(void)checkVersion {
    
    [self showActivityIndicator];
    [[MONetDataServer sharedMONetDataServer] checkVersionWithAppType:2 appId:1 success:^(NSDictionary *dic) {
        [self hidenActivityIndicator];
        MOCheckVersionModel *model = [MOCheckVersionModel yy_modelWithJSON:dic];
        if ([model.ver_name compare:APPVersionString] == NSOrderedDescending) {
            [MOMsgAlertView showWithTitle:NSLocalizedString(@"升级提醒", nil) andMsg:NSLocalizedString(@"当前App有新版本是否立即升级", nil) andSureClickHandle:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://apps.apple.com/cn/app/%E5%A2%A8%E6%AF%94%E4%B9%8C%E6%96%AF-%E6%95%B0%E6%8D%AE%E5%88%9B%E9%80%A0%E4%BB%B7%E5%80%BC-%E5%8F%82%E4%B8%8Eai%E6%9C%AA%E6%9D%A5/id6737462102"] options:@{} completionHandler:NULL];
            }];
        } else {
            
            [self showMessage:NSLocalizedString(@"当前app已是最新版本", nil)];
        }
        
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

#pragma mark - methods
// 上传头像选择窗口
- (void)showUploadAvatarSheet {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingVideo = NO;
    NSMutableArray *imageAssets = @[].mutableCopy;
    imagePickerVc.selectedAssets = imageAssets;
    imagePickerVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePickerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *selectImage = photos[0];
            [self uploadUserAvatar:selectImage];
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}

///设置头像
- (void)uploadUserAvatar:(UIImage *)avatar {
    MBProgressHUD *hud = [MBProgressHUD showCycleLoadingMessag:@"" toView:MOAppDelegate.window];

    [[MONetDataServer sharedMONetDataServer] uploadImage:avatar success:^(NSDictionary *dic) {
        NSString *relateUrl = dic[@"relative_url"];
        NSString *showUrl = dic[@"url"];

        [[MONetDataServer sharedMONetDataServer] modifyUserInfoWithUserName:@"" avatar:relateUrl sex:0 mobile:@"" describe:@"" native_city:@"" native_city_code:@"" native_province:@"" native_province_code:@"" success:^(NSDictionary *dic) {
            [hud hide:YES];
            [MBProgressHUD showMessag:NSLocalizedString(@"头像上传成功", nil) toView:MOAppDelegate.window];
            [self.userAvatar sd_setImageWithURL:[NSURL URLWithString:showUrl] placeholderImage:[UIImage imageNamedNoCache:@"icon_user_avatar"]];
        
            MOUserModel *userModel = [MOUserModel unarchiveUserModel];
            userModel.avatar = showUrl;
            [userModel archivedUserModel];
        } failure:^(NSError *error) {
            [hud hide:YES];
            [MBProgressHUD showError:NSLocalizedString(@"上传头像失败", nil) toView:MOAppDelegate.window];
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
}

#pragma mark - Cache Management

// 计算缓存大小
- (void)calculateCacheSizeWithCompletion:(void (^)(NSString *sizeString))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取缓存目录和临时目录
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *tempPath = NSTemporaryDirectory();
        
        // 计算总大小
        unsigned long long totalSize = 0;
        totalSize += [self folderSizeAtPath:cachePath];
        totalSize += [self folderSizeAtPath:tempPath];
        
        // 转换为可读字符串
        NSString *sizeString = [self formatSize:totalSize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(sizeString);
            }
        });
    });
}

// 清理缓存
- (void)clearCacheWithCompletion:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获取缓存目录和临时目录
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *tempPath = NSTemporaryDirectory();
        
        // 清理目录
        [self clearDirectoryAtPath:cachePath];
        [self clearDirectoryAtPath:tempPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

#pragma mark - Helper Methods

// 计算指定路径文件夹大小
- (unsigned long long)folderSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long size = 0;
    
    // 遍历目录下的所有文件
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    for (NSString *subPath in enumerator) {
        NSString *fullPath = [path stringByAppendingPathComponent:subPath];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
        size += [attributes[NSFileSize] unsignedLongLongValue];
    }
    
    return size;
}

// 清理指定路径下的所有文件
- (void)clearDirectoryAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    
    for (NSString *subPath in enumerator) {
        NSString *fullPath = [path stringByAppendingPathComponent:subPath];
        NSError *error;
        [fileManager removeItemAtPath:fullPath error:&error];
        if (error) {
            DLog(@"清理文件失败: %@ - %@", fullPath, error.localizedDescription);
        }
    }
}

// 将字节大小格式化为可读字符串（KB、MB、GB）
- (NSString *)formatSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu B", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f KB", size / 1024.0];
    } else if (size < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f MB", size / (1024.0 * 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.2f GB", size / (1024.0 * 1024.0 * 1024.0)];
    }
}

@end
