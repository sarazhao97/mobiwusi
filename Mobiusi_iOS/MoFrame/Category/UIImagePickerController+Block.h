//
//  UIImagePickerController+Block.h
//  Trust
//
//  Created by zhangxiaoliang01 on 2021/4/13.
//  Copyright © 2021 com.msxf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImagePickerController (Block)<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,copy)void(^didFinishPickingMediaWithInfo)(UIImagePickerController *imagePicker,NSDictionary<UIImagePickerControllerInfoKey,id> *Info);
@property(nonatomic,copy)void(^didCancel)(UIImagePickerController *imagePicker);
@end

NS_ASSUME_NONNULL_END
