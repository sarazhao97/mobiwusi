//
//  MOPictureFillTaskTopicVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/24.
//

#import "MOPictureFillTaskTopicVC.h"
#import "MORecordTaskAlertView.h"
#import "MOPictureVideoFillTaskStep2View.h"
#import "MOPictureVideoStep2PlaceholderCell.h"
#import "MOPictureVideoStep2HeaderView.h"
#import "MOOnlyTextStepView.h"
#import "UIImagePickerController+Block.h"
#import "NSObject+KVO.h"
#import "MOAttchmentFileInfoModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MOUploadFileDataModel.h"
#import "MOBrowseMediumVC.h"
#import "MOMyPictureDataVC.h"
#import <TZImagePickerController.h>
#import "UIImage+tool.h"

@interface MOPictureFillTaskTopicVC ()
@property(nonatomic,strong)NSMutableArray<MOAttchmentImageFileInfoModel *> *imageList;
@property(nonatomic,assign)NSInteger componentCount;
@end

@implementation MOPictureFillTaskTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.myDataBtn setTitles:NSLocalizedString(@"我的图片", nil)];
    WEAKSELF
    self.didMyDataBtnClick = ^{
        MONavigationController *nav = [MOMyPictureDataVC creatPresentationCustomStyleWithNavigationRootVCWithCate:2 userTaskId:weakSelf.taskModel.user_task_id];
        [MOAppDelegate.transition.topViewController presentViewController:nav animated:YES completion:NULL];
    };
}

-(void)configUIAfterReceivingData {
    [super configUIAfterReceivingData];
    
    self.componentCount = 3;
    
    self.step1View.titleLabel.text = StringWithFormat(@"Step1：%@",NSLocalizedString(@"阅读图片要求", nil));
    [[self mutableArrayValueForKey:@"imageList"] removeAllObjects];
    
    if (self.taskModel.is_need_describe) {
        
        [self.step2View mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.step1View.mas_bottom).offset(11);
        }];
        
        
        self.step3View = [MOOnlyTextStepView new];
        self.step3View.titleLabel.text = StringWithFormat(@"Step3：%@",NSLocalizedString(@"输入文本内容", nil));
        self.componentCount++;
        [self.scrollContentView addSubview:self.step3View];
        [self.step3View mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.step2View.mas_bottom).offset(18);
            make.bottom.equalTo(self.scrollContentView.mas_bottom);
        }];
        
        
    } else {
        
        [self.step2View mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.step1View.mas_bottom).offset(11);
            make.bottom.equalTo(self.scrollContentView.mas_bottom);
        }];
        
    }
    
    
    WEAKSELF
    [self observeValueForKeyPath:@"imageList" chnageBlck:^(NSDictionary * _Nonnull change, id  _Nonnull object) {
        
        if (![weakSelf canEdit]) {
            [weakSelf showBottomView];
            return;
        }
        if (weakSelf.step3View.textInput && [weakSelf.step3View.textInput.text length]&&weakSelf.imageList.count == weakSelf.taskModel.limit_of_one_upload_image) {
            [weakSelf showBottomView];
        } else if(!weakSelf.step3View.textInput && weakSelf.taskModel.limit_of_one_upload_image == weakSelf.imageList.count) {
            [weakSelf showBottomView];
        } else {
            [weakSelf hiddenBottomView];
        }
    }];
    
    //监听,在填充数据，
    MOTaskQuestionModel *model = self.questionDetail.data[self.currentQuestionIndex];
    self.step3View.textInput.text = model.text_data;
    for (MOTaskQuestionDataModel *picModel in model.picture_data) {
        
        MOAttchmentImageFileInfoModel *imagemMdel = [MOAttchmentImageFileInfoModel new];
        imagemMdel.fileId = picModel.model_id;
        imagemMdel.fileName = picModel.file_name;
        imagemMdel.fileServerUrl = picModel.url;
        imagemMdel.fileStatus = picModel.status;
        imagemMdel.errorMsg = picModel.remark;
        [[self mutableArrayValueForKey:@"imageList"] addObject:imagemMdel];
        
    }
    [self.step2View.pictureVideoCollectionView reloadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        if (weakSelf.step3View.textInput == notification.object) {
            if ([weakSelf.step3View.textInput.text length] && weakSelf.taskModel.limit_of_one_upload_image == weakSelf.imageList.count) {
                
                [weakSelf showBottomView];
            } else{
                [weakSelf hiddenBottomView];
            }
        }
    }];
    
    self.step3View.textInput.editable = [self canEdit];
    
    self.bottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Step%ld：确认数据", nil),(long)self.componentCount];
    
}

-(void)submitData {
    
    
    WEAKSELF
    [self showActivityIndicator];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("uploadFile", DISPATCH_QUEUE_CONCURRENT);
    __block BOOL uploadFail = NO;
    for (MOAttchmentImageFileInfoModel *model in weakSelf.imageList) {
        
        
        if ((model.fileStatus == 0 || model.fileStatus == 3) && model.image) {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                
                NSString *mineType = @"";
                mineType = @"image/jpeg";
                NSString *pathExtension = [model.fileName pathExtension];
                if ([pathExtension containsString:@"jpg"] || [[model.fileName pathExtension] containsString:@"jpeg"]) {
                    mineType = @"image/jpeg";
                }
                if ([pathExtension containsString:@"png"]) {
                    mineType = @"image/png";
                }
                if ([pathExtension containsString:@"heic"]) {
                    mineType = @"image/heic";
                }
                if ([pathExtension containsString:@"heicf"]) {
                    mineType = @"image/heif";
                }
                if ([pathExtension containsString:@"tiff"]) {
                    mineType = @"image/tiff";
                }
                if ([pathExtension containsString:@"gif"]) {
                    mineType = @"image/gif";
                }
                [[TZImageManager manager] requestImageDataForAsset:model.imageAsset completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    
                    NSData *getImageData = imageData;
                    model.fileData = imageData;
                    [[MONetDataServer sharedMONetDataServer] uploadFileWithFileName:model.fileName fileData:getImageData mimeType:mineType success:^(NSDictionary *dic) {
                        model.fileServerRelativeUrl = dic[@"relative_url"];
                        model.fileServerUrl = dic[@"url"];
                        dispatch_group_leave(group);
                    } failure:^(NSError *error) {
                        uploadFail = YES;
                        dispatch_group_leave(group);
                    } loginFail:^{
						dispatch_async(dispatch_get_main_queue(), ^{
							[self hidenActivityIndicator];
						});
                        uploadFail = YES;
                        dispatch_group_leave(group);
                    }];
                    
                } progressHandler:NULL];
                
            });
        }
        
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        if (uploadFail) {
            [weakSelf hidenActivityIndicator];
            [weakSelf showErrorMessage:NSLocalizedString(@"文件上传失败", nil)];
            return;
        }
        NSString *imageFileJsonString = nil;
        if (weakSelf.taskModel.limit_of_one_upload_image > 0 ) {
            
            NSMutableArray *json = @[].mutableCopy;
            for (MOAttchmentImageFileInfoModel *model in weakSelf.imageList) {
                if ((model.fileStatus == 0 || model.fileStatus == 3) && model.fileServerRelativeUrl.length) {
                    MOUploadPictureFileDataModel *picModel = [MOUploadPictureFileDataModel new];
                    picModel.file_name = model.fileName;
                    picModel.model_id = model.fileId;
                    picModel.format = model.fileExtension;
                    picModel.quality = [NSString stringWithFormat:@"%ldx%ld",(NSInteger)model.image.size.width,(long)model.image.size.height];
                    picModel.size = model.fileData.length;
                    picModel.url = model.fileServerRelativeUrl;
                    picModel.location = model.location;
                    [json addObject:picModel];
                }
                
            }
            imageFileJsonString = [json yy_modelToJSONString];
        }
        
        
        NSString *textData = nil;
        if (weakSelf.taskModel.is_need_describe) {
            textData = weakSelf.step3View.textInput.text;
        }
       
        
        MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
        [[MONetDataServer sharedMONetDataServer] finishTopicWithTaskId:weakSelf.taskModel.task_id user_task_id:weakSelf.taskModel.user_task_id result_id:questionMode.model_id text_data:textData picture_data:imageFileJsonString audio_data:nil file_data:nil video_data:nil success:^(NSDictionary *dic) {
            
            [weakSelf hidenActivityIndicator];
            questionMode.status = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:CompletedOneTopic object:nil userInfo:@{@"currentQuestionIndex":@(weakSelf.currentQuestionIndex)}];
            if (weakSelf.currentQuestionIndex + 1 == weakSelf.questionDetail.count) {
                weakSelf.taskModel.task_status = @(2);
                if (weakSelf.taskStatusChangeed) {
                    weakSelf.taskStatusChangeed(2);
                }
                [MOAppDelegate.transition popViewControllerAnimated:YES];
                return;
            }
			
			//还原数据，以方便点击查看刚提交的数据
			NSMutableArray *picture_data = @[].mutableCopy;
			for (MOAttchmentImageFileInfoModel *model in weakSelf.imageList) {
				MOTaskQuestionDataModel *fileModel = [MOTaskQuestionDataModel new];
				fileModel.url = model.fileServerUrl;
				fileModel.model_id = model.fileId;
				fileModel.cate = 2;
				fileModel.status = 1;
				fileModel.file_name = model.fileName;
				[picture_data addObject:fileModel];
			}
			questionMode.picture_data = picture_data;
			questionMode.text_data = textData;
            weakSelf.currentQuestionIndex ++;
			weakSelf.selectQuestionLimitIndex = weakSelf.currentQuestionIndex;
            [weakSelf resetUI];
            
            DLog(@"%@",dic);
            
        } failure:^(NSError *error) {
            [weakSelf hidenActivityIndicator];
            [weakSelf showErrorMessage:error.localizedDescription];
        } msg:^(NSString *string) {
            [weakSelf hidenActivityIndicator];
            [weakSelf showErrorMessage:string];
        } loginFail:^{
            [weakSelf hidenActivityIndicator];
        }];
        
    });
}


-(void)resetUI {
    
    [self configUIAfterReceivingData];
}


-(void)goPickeImages {
    WEAKSELF
    [self goPickeImagesWithMaxCount:self.taskModel.limit_of_one_upload_image selectedAssets:self.imageList complete:^(NSArray<MOAttchmentVideoFileInfoModel *> *modelList) {
        
        [[weakSelf mutableArrayValueForKeyPath:@"imageList"] removeAllObjects];
        [[weakSelf mutableArrayValueForKeyPath:@"imageList"] addObjectsFromArray:modelList];
        [weakSelf.step2View.pictureVideoCollectionView reloadData];
    }];
}

-(void)goPickeImagesWithMaxCount:(NSInteger)maxCount selectedAssets:(NSArray *)selectedAssets complete:(void(^)(NSArray<MOAttchmentImageFileInfoModel *> *modelList))complete{
    
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount delegate:nil];
    imagePickerVc.allowPickingVideo = NO;
    NSMutableArray *imageAssets = @[].mutableCopy;
    for (MOAttchmentImageFileInfoModel *model in selectedAssets) {
        if (model.imageAsset) {
            [imageAssets addObject:model.imageAsset];
        }
        
    }
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.selectedAssets = imageAssets;
    imagePickerVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePickerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    WEAKSELF
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        unsigned int imageCount = (unsigned int)photos.count;
        NSMutableArray *tmp = @[].mutableCopy;
        BOOL hasUnsupportType = NO;
        for (int i = 0; i < imageCount; i++) {
            PHAsset *itemAsset = assets[i];
            NSString *extension = [weakSelf getFormatOfAsset:itemAsset];
            if ([weakSelf.taskModel.file_type containsString:extension]) {
                UIImage *itemImage = photos[i];
                MOAttchmentImageFileInfoModel *model = [MOAttchmentImageFileInfoModel new];
                model.image = itemImage;
                model.quality = [NSString stringWithFormat:@"%ldx%ld",(NSInteger)itemImage.size.width,(long)itemImage.size.height];
                model.fileName = [NSString stringWithFormat:@"%@.%@",[NSUUID UUID].UUIDString,extension];
                model.fileExtension = extension;
                
                model.location = [NSString stringWithFormat:@"%f,%f",itemAsset.location.coordinate.latitude,itemAsset.location.coordinate.longitude];
                model.imageAsset = itemAsset;
                [tmp addObject:model];
            } else {
                hasUnsupportType = YES;
            }
        }
        if (complete) {
            if (hasUnsupportType) {
                [weakSelf showMessage:NSLocalizedString(@"已过滤不支持的格式", nil)];
            }
            complete(tmp);
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}
-(NSString *)getFormatOfAsset:(PHAsset *)asset {
    // 获取与 PHAsset 关联的所有资源
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
    for (PHAssetResource *resource in resources) {
        NSString *uti = resource.uniformTypeIdentifier;
        if ([uti isEqualToString:@"public.jpeg"]) {
            return @"jpeg";
        } else if ([uti isEqualToString:@"public.png"]) {
            return @"png";
        } else if ([uti isEqualToString:@"com.compuserve.gif"]) {
            return @"gif";
        } else if ([uti isEqualToString:@"public.tiff"]) {
            return @"tiff";
        } else if ([uti isEqualToString:@"public.heic"]) {
            return @"heic";
        } else if ([uti isEqualToString:@"public.heif"]) {
            return @"heif";
        }
    }
    return @"Unknown";
}


#pragma mark UICollectionViewDelegate,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return  1;
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.imageList.count >= self.taskModel.limit_of_one_upload_image) {
        
        return self.imageList.count;
    } else {
        
        return self.imageList.count + 1;
    }
}
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 36);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        MOTaskQuestionModel *model = self.questionDetail.data[self.currentQuestionIndex];
        MOPictureVideoStep2HeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MOPictureVideoStep2HeaderView" forIndexPath:indexPath];
        header.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"图片（%lu/%ld）", nil),(unsigned long)self.imageList.count,(long)self.taskModel.limit_of_one_upload_image];
        if (self.imageList.count == 0 && model.status == 0)  {
            NSString *tipStr = [NSString stringWithFormat:NSLocalizedString(@"需上传%ld张图片", nil),(long)self.taskModel.limit_of_one_upload_image];
            [header setWanringTitle:tipStr];
            header.completeBtn.hidden = NO;
        }
        if (self.imageList.count > 0 && model.status == 0) {
            NSString *tipStr = [NSString stringWithFormat:NSLocalizedString(@"需再上传%ld张图片", nil),(long)self.taskModel.limit_of_one_upload_image - self.imageList.count];
            [header setWanringTitle:tipStr];
            header.completeBtn.hidden = NO;
        }
        if (self.imageList.count == self.taskModel.limit_of_one_upload_image && model.status == 0) {
            header.completeBtn.hidden = NO;
            [header setSuccessTitle:NSLocalizedString(@"上传成功", nil)];
            
        }
        
        if (model.status != 0) {
            header.completeBtn.hidden = YES;
        }
        
        
        return header;
    }
    
    return nil;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    
    if (self.imageList.count - 1 >= indexPath.item && self.imageList.count != 0) {
        MOFillTaskVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOFillTaskVideoCell" forIndexPath:indexPath];
        
        NSInteger index = indexPath.item;
        MOAttchmentImageFileInfoModel *model = self.imageList[index];
        cell.deleteBtn.hidden = !([self canSubmitData] && model.fileStatus == 0);
        [cell configImageCellWithModel:model];
        cell.failurePromptView.hidden = !([self.taskModel.task_status integerValue] == 3 && model.fileStatus == 3);
        WEAKSELF
        cell.didDeleteBtnClick = ^{
            
            [[weakSelf mutableArrayValueForKey:@"imageList"] removeObjectAtIndex:index];
            [weakSelf.step2View.pictureVideoCollectionView reloadData];
        };
        
        cell.didErrorIconClick = ^{
            
            [weakSelf goPickeImagesWithMaxCount:1 selectedAssets:@[model] complete:^(NSArray<MOAttchmentImageFileInfoModel *> *modelList) {
                MOAttchmentImageFileInfoModel *replaceModel = modelList.firstObject;
                replaceModel.fileId = model.fileId;
                replaceModel.fileStatus = model.fileStatus;
                [[weakSelf mutableArrayValueForKeyPath:@"imageList"] replaceObjectAtIndex:indexPath.item withObject:replaceModel];
                [weakSelf.step2View.pictureVideoCollectionView reloadData];
            }];
        };
        return cell;
    }
    MOPictureVideoStep2PlaceholderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOPictureVideoStep2PlaceholderCell" forIndexPath:indexPath];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
    if (questionMode.status != 0) {
        
        NSMutableArray *dataList = @[].mutableCopy;
        for (MOAttchmentImageFileInfoModel *model in self.imageList) {
            MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
            imageModel.type = MOBrowseMediumItemTypeImage;
            imageModel.url = model.fileServerUrl;
            imageModel.image = model.image;
            [dataList addObject:imageModel];
        }
        MOBrowseMediumVC *vc = [[MOBrowseMediumVC alloc] initWithDataList:dataList selectedIndex:indexPath.item];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:NULL];
        return;
    }
    
    if ([questionMode status] == 0) {
        
        [self goPickeImages];
    }
    
    
}


-(NSMutableArray<MOAttchmentImageFileInfoModel *> *)imageList {
    
    if (!_imageList) {
        _imageList = @[].mutableCopy;
    }
    return _imageList;
}
@end
