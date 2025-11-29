//
//  UIImagePickerController+Block.m
//  Trust
//
//  Created by zhangxiaoliang01 on 2021/4/13.
//  Copyright © 2021 com.msxf. All rights reserved.
//

#import "UIImagePickerController+Block.h"
@interface UIImagePickerController(CountDown)

@end

static const char *didFinishPickingMediaWithInfo = "didFinishPickingMediaWithInfo";
static const char *didCancel = "didCancel";

@implementation UIImagePickerController (Block)

-(void)setDidFinishPickingMediaWithInfo:(void (^)(UIImagePickerController * _Nonnull, NSDictionary<UIImagePickerControllerInfoKey,id> * _Nonnull))didFinishPickingMediaWithInfo1 {
    
    objc_setAssociatedObject(self, &didFinishPickingMediaWithInfo, didFinishPickingMediaWithInfo1, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void (^)(UIImagePickerController * _Nonnull , NSDictionary<UIImagePickerControllerInfoKey,id> * _Nonnull))didFinishPickingMediaWithInfo {
    
    return  objc_getAssociatedObject(self, &didFinishPickingMediaWithInfo);
}

-(void)setDidCancel:(void (^)(UIImagePickerController * _Nonnull))didCancel1 {
    
    objc_setAssociatedObject(self, &didCancel, didCancel1, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void(^)(UIImagePickerController *_Nonnull))didCancel {
    
    return  objc_getAssociatedObject(self, &didCancel);
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{

    if (self.didFinishPickingMediaWithInfo) {
        self.didFinishPickingMediaWithInfo(picker,info);
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if (self.didCancel) {
        self.didCancel(picker);
    }
}

@end
