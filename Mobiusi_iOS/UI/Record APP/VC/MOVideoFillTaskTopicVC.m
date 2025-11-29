//
//  MOVideoFillTaskTopicVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import "MOVideoFillTaskTopicVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSObject+KVO.h"
#import "MOUploadFileDataModel.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "MOBrowseMediumVC.h"
#import "MOMyVideoDataVC.h"
#import <TZImagePickerController.h>

#define TmpSaveVideoDirectory  @"tmpSaveVideo"

@interface MOVideoFillTaskTopicVC ()
@property(nonatomic,strong)NSMutableArray<MOAttchmentImageFileInfoModel *> *imageList;
@property(nonatomic,strong)NSMutableArray<MOAttchmentVideoFileInfoModel *> *videoList;
@property(nonatomic,assign)NSInteger componentCount;
@end

@implementation MOVideoFillTaskTopicVC


- (void)viewDidLoad {
    [super viewDidLoad];
    WEAKSELF
    self.didMyDataBtnClick = ^{
        MONavigationController *nav = [MOMyVideoDataVC creatPresentationCustomStyleWithNavigationRootVCWithCate:4 userTaskId:weakSelf.taskModel.user_task_id];
        [MOAppDelegate.transition.topViewController presentViewController:nav animated:YES completion:NULL];
    };
    
}

-(void)configUIAfterReceivingData {
    [super configUIAfterReceivingData];
    
    self.componentCount = 3;
    [self.myDataBtn setTitles:NSLocalizedString(@"我的视频",nil)];
    self.step1View.titleLabel.text = NSLocalizedString(@"Step1：阅读视频要求", nil);
    [self.scrollContentView addSubview:self.step2View];
    [[self mutableArrayValueForKey:@"imageList"] removeAllObjects];
    [[self mutableArrayValueForKey:@"videoList"] removeAllObjects];
    
    if (self.taskModel.is_need_describe) {
        
        [self.step2View mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.scrollContentView.mas_left);
            make.right.equalTo(self.scrollContentView.mas_right);
            make.top.equalTo(self.step1View.mas_bottom).offset(11);
        }];
        
        
        self.step3View = [MOOnlyTextStepView new];
        self.step3View.titleLabel.text = NSLocalizedString(@"Step3：输入文本内容", nil);
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
    
    
    [self observeValueForKeyPath:@"videoList" chnageBlck:^(NSDictionary * _Nonnull change, id  _Nonnull object) {
        
        if (![weakSelf canEdit]) {
            [weakSelf showBottomView];
            return;
        }
        if (weakSelf.step3View.textInput && [weakSelf.step3View.textInput.text length] && weakSelf.imageList.count == weakSelf.taskModel.limit_of_one_upload_image && weakSelf.videoList.count == weakSelf.taskModel.limit_of_one_upload_video) {
            [weakSelf showBottomView];
        } else if(!weakSelf.step3View.textInput && weakSelf.imageList.count == weakSelf.taskModel.limit_of_one_upload_image && weakSelf.videoList.count == weakSelf.taskModel.limit_of_one_upload_video) {
            [weakSelf showBottomView];
        } else {
            [weakSelf hiddenBottomView];
        }
    }];
    
    [self observeValueForKeyPath:@"imageList" chnageBlck:^(NSDictionary * _Nonnull change, id  _Nonnull object) {
        
        if (![weakSelf canEdit]) {
            [weakSelf showBottomView];
            return;
        }
        if (weakSelf.step3View.textInput && [weakSelf.step3View.textInput.text length] && weakSelf.imageList.count == weakSelf.taskModel.limit_of_one_upload_image && weakSelf.videoList.count == weakSelf.taskModel.limit_of_one_upload_video) {
            [weakSelf showBottomView];
        } else if(!weakSelf.step3View.textInput && weakSelf.imageList.count == weakSelf.taskModel.limit_of_one_upload_image && weakSelf.videoList.count == weakSelf.taskModel.limit_of_one_upload_video) {
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
    for (MOTaskQuestionDataModel *picModel in model.video_data) {
        
        MOAttchmentVideoFileInfoModel *videoMdel = [MOAttchmentVideoFileInfoModel new];
        videoMdel.fileId = picModel.model_id;
        videoMdel.fileName = picModel.file_name;
        videoMdel.fileServerUrl = picModel.url;
        videoMdel.thumbnailUrl = picModel.snapshot;
        videoMdel.fileStatus = picModel.status;
        videoMdel.errorMsg = picModel.remark;
        [[self mutableArrayValueForKey:@"videoList"] addObject:videoMdel];
        
    }
    [self.step2View.pictureVideoCollectionView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextViewTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        
        if (weakSelf.step3View.textInput == notification.object) {
            if ([weakSelf.step3View.textInput.text length] && weakSelf.imageList.count == weakSelf.taskModel.limit_of_one_upload_image && weakSelf.videoList.count == weakSelf.taskModel.limit_of_one_upload_video) {
                
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
    for (MOAttchmentVideoFileInfoModel *model in weakSelf.videoList) {
        
        if ((model.fileStatus == 0 || model.fileStatus == 3) && model.fileData) {
            
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                
                NSString *mineType = @"";
                if ([model.fileExtension containsString:@"MOV"]) {
                    mineType = @"video/quicktime";
                }
                if ([model.fileExtension containsString:@"mp4"]) {
                    mineType = @"video/mp4";
                }
                
                [[MONetDataServer sharedMONetDataServer] uploadFileWithFileName:model.fileName fileData:model.fileData mimeType:mineType success:^(NSDictionary *dic) {
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
            });
        }
        
    }
    
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
                if ([pathExtension containsString:@"tiff"]) {
                    mineType = @"image/tiff";
                }
                if ([pathExtension containsString:@"gif"]) {
                    mineType = @"image/gif";
                }
                if ([pathExtension containsString:@"heicf"]) {
                    mineType = @"image/heif";
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
        NSString *videoFileJsonString = nil;
        NSMutableArray *videoJson = @[].mutableCopy;
        for (MOAttchmentVideoFileInfoModel *model in weakSelf.videoList) {
            if ((model.fileStatus == 0 || model.fileStatus == 3) && model.fileServerRelativeUrl) {
                MOUploadVideoFileDataModel *picModel = [MOUploadVideoFileDataModel new];
                picModel.file_name = model.fileName;
                picModel.model_id = model.fileId;
                picModel.format = model.fileExtension;
                picModel.quality = model.quality;
                picModel.url = model.fileServerRelativeUrl;
                picModel.size = model.fileData.length;
                picModel.duration = model.duration;
                [videoJson addObject:picModel];
            }
            
        }
        videoFileJsonString = [videoJson yy_modelToJSONString];
        
        NSString *imageFileJsonString = nil;
        NSMutableArray *imagejson = weakSelf.imageList.count?@[].mutableCopy:nil;
        for (MOAttchmentImageFileInfoModel *model in weakSelf.imageList) {
            if ((model.fileStatus == 0 || model.fileStatus == 3) && model.fileServerRelativeUrl) {
                MOUploadPictureFileDataModel *picModel = [MOUploadPictureFileDataModel new];
                picModel.file_name = model.fileName;
                picModel.model_id = model.fileId;
                picModel.format = model.fileExtension;
                picModel.quality = [NSString stringWithFormat:@"%ldx%ld",(NSInteger)model.image.size.width,(long)model.image.size.height];
                picModel.size = [model.fileData length];
                picModel.url = model.fileServerRelativeUrl;
                picModel.location = model.location;
                [imagejson addObject:picModel];
            }
            
        }
        imageFileJsonString = [imagejson yy_modelToJSONString];
        
        
        NSString *textData = nil;
        if (weakSelf.taskModel.is_need_describe) {
            textData = weakSelf.step3View.textInput.text;
            
        }
       
        MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
        [[MONetDataServer sharedMONetDataServer] finishTopicWithTaskId:weakSelf.taskModel.task_id user_task_id:weakSelf.taskModel.user_task_id result_id:questionMode.model_id text_data:textData picture_data:imageFileJsonString audio_data:nil file_data:nil video_data:videoFileJsonString success:^(NSDictionary *dic) {
            
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
            weakSelf.currentQuestionIndex ++;
			weakSelf.selectQuestionLimitIndex = weakSelf.currentQuestionIndex;
			NSMutableArray *video_data = @[].mutableCopy;
			for (MOAttchmentVideoFileInfoModel *model in weakSelf.videoList) {
				MOTaskQuestionDataModel *fileModel = [MOTaskQuestionDataModel new];
				fileModel.model_id = model.fileId;
				fileModel.url = model.fileServerUrl;
				fileModel.status = 1;
				fileModel.file_name = model.fileName;
				fileModel.cate = 4;
				[video_data addObject:fileModel];
			}
			questionMode.video_data = video_data;
			
			NSMutableArray *picture_data = @[].mutableCopy;
			for (MOAttchmentVideoFileInfoModel *model in weakSelf.imageList) {
				MOTaskQuestionDataModel *fileModel = [MOTaskQuestionDataModel new];
				fileModel.model_id = model.fileId;
				fileModel.url = model.fileServerUrl;
				fileModel.status = 1;
				fileModel.file_name = model.fileName;
				fileModel.cate = 2;
				[picture_data addObject:fileModel];
			}
			questionMode.picture_data = picture_data;
			questionMode.text_data = textData;
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

-(void)goPickVideo {
    
    WEAKSELF
    [self goPickVideoWithMaxCount:self.taskModel.limit_of_one_upload_video selectedAssets:self.videoList complete:^(NSArray<MOAttchmentVideoFileInfoModel *> *modelList) {
        
        [[weakSelf mutableArrayValueForKey:@"videoList"] removeAllObjects];
        [[weakSelf mutableArrayValueForKey:@"videoList"] addObjectsFromArray:modelList];
        [weakSelf.step2View.pictureVideoCollectionView reloadData];
    }];
}

-(void)goPickVideoWithMaxCount:(NSInteger)maxCount selectedAssets:(NSArray *)selectedAssets complete:(void(^)(NSArray<MOAttchmentVideoFileInfoModel *> *modelList))complete{
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxCount delegate:nil ];
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.allowPickingMultipleVideo = YES;
    imagePickerVc.showSelectBtn = YES;
    NSMutableArray *imageAssets = @[].mutableCopy;
    for (MOAttchmentVideoFileInfoModel *model in selectedAssets) {
        if (model.videoAsset) {
            [imageAssets addObject:model.videoAsset];
        }
        
    }
    imagePickerVc.selectedAssets = imageAssets;
    imagePickerVc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePickerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    imagePickerVc.uiImagePickerControllerSettingBlock = ^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    };
    // 设置完成选择的 block 回调
    WEAKSELF
    imagePickerVc.didFinishPickingVideoHandle = ^(UIImage *coverImage, PHAsset *asset) {
        // 此回调用于单选视频
        [weakSelf batchProcessVideos:@[asset] complete:^(NSArray<MOAttchmentVideoFileInfoModel *> *modelList) {
            
            if (complete) {
                complete(modelList);
            }
        }];
    };
    imagePickerVc.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        [weakSelf batchProcessVideos:assets complete:^(NSArray<MOAttchmentVideoFileInfoModel *> *modelList) {
            if (complete) {
                complete(modelList);
            }
        }];
        
    };
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
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
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.showSelectBtn = YES;
    NSMutableArray *imageAssets = @[].mutableCopy;
    for (MOAttchmentImageFileInfoModel *model in selectedAssets) {
        if (model.imageAsset) {
            [imageAssets addObject:model.imageAsset];
        }
        
    }
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


-(void)batchProcessVideos:(NSArray <PHAsset *>*)videos complete:(void(^)(NSArray<MOAttchmentVideoFileInfoModel *>* modelList))complete{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("BatchprocessVideos", 0);
    [self  showActivityIndicator];
    WEAKSELF
    NSMutableArray *modelList = @[].mutableCopy;
    __block BOOL exportFail = NO;
    for (PHAsset *item in videos) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            
            [self proccessVideoWithAsset:item complete:^(NSURL *outputURL, BOOL success) {
                if (success) {
                    MOAttchmentVideoFileInfoModel *model = [weakSelf createVideoWithUrl:outputURL];
                    model.videoAsset = item;
                    [modelList addObject:model];
                }else {
                    exportFail = NO;
                }
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self  hidenActivityIndicator];
        if (exportFail) {
            [self showErrorMessage:NSLocalizedString(@"部分视频导出失败", nil)];
        }
        if (complete) {
            complete(modelList);
        }
    });
}

-(void)proccessVideoWithAsset:(PHAsset *)item complete:(void(^)(NSURL *outputURL, BOOL success))complete{
    
    WEAKSELF
    [[TZImageManager manager] getVideoWithAsset:item completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        AVURLAsset *tmp = (AVURLAsset *)playerItem.asset;
        if ([[tmp.URL.pathExtension lowercaseString] isEqualToString:@"mp4"]) {
            
            [weakSelf downloadVideoWith:tmp.URL completion:^(NSURL *outputURL, BOOL success) {
                
                if (complete) {
                    complete(outputURL,success);
                }
            }];
            
        } else {
            [weakSelf convertMOVToMP4:tmp.URL completion:^(NSURL *outputURL, BOOL success) {
                if (complete) {
                    complete(outputURL,success);
                }
                
            }];
        }
    }];
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
        }
        else if ([uti isEqualToString:@"public.heif"]) {
           return @"heif";
       }
    }
    return @"Unknown";
}

-(MOAttchmentVideoFileInfoModel *)createVideoWithUrl:(NSURL *)videoUrl {
    // 获取视频缩略图
    UIImage *thumbnail = [self getVideoThumbnail:videoUrl];
    NSTimeInterval floatsecond = [self getVideoDuration:videoUrl];
    // 获取视频分辨率
    CGSize resolution = [self getVideoResolution:videoUrl];
    MOAttchmentVideoFileInfoModel *model = [MOAttchmentVideoFileInfoModel new];
    model.fileData = [NSData dataWithContentsOfFile:videoUrl.path];
    model.fileName = videoUrl.path.lastPathComponent;
    model.fileExtension = videoUrl.path.lastPathComponent.pathExtension;
    model.locationMediaURL = videoUrl;
    model.thumbnail = thumbnail;
    model.quality = [NSString stringWithFormat:@"%.0fx%.0f",resolution.width, resolution.height];
    model.duration = floatsecond * 1000;
    return model;
}


-(void)downloadVideoWith:(NSURL *)inputURL completion:(void (^)(NSURL *outputURL, BOOL success))completion {
    
    NSString *outputPath = [self createTmpSaveVideoPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[NSUUID UUID].UUIDString];
    outputPath = [outputPath stringByAppendingPathComponent:fileName];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    // 创建NSURLSessionConfiguration对象
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 设置缓存策略为NSURLRequestReturnCacheDataElseLoad
    configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    // 创建NSURLSession对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    // 创建NSURLRequest对象
    NSURLRequest *request = [NSURLRequest requestWithURL:inputURL];
    // 发起网络请求
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion(outputURL,YES);
            } else {
                [data writeToURL:outputURL atomically:YES];
                if (completion) {
                    completion(outputURL,YES);
                }
            }
        });
        
    }];
    [task resume];
    
}

- (void)convertMOVToMP4:(NSURL *)inputURL completion:(void (^)(NSURL *outputURL, BOOL success))completion {
    AVAsset *asset = [AVAsset assetWithURL:inputURL];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    NSString *outputPath = [self createTmpSaveVideoPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[NSUUID UUID].UUIDString];
    outputPath = [outputPath stringByAppendingPathComponent:fileName];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted:
                    completion(outputURL, YES);
                    break;
                case AVAssetExportSessionStatusFailed:
                    DLog(@"视频转换失败: %@", exportSession.error.localizedDescription);
                    completion(nil, NO);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    DLog(@"视频转换取消");
                    completion(nil, NO);
                    break;
                default:
                    completion(nil, NO);
                    break;
            }
        });
        
    }];
}

- (UIImage *)getVideoThumbnail:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error;
    CMTime actualTime;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (imageRef) {
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return thumbnail;
    }
    return nil;
}

- (NSTimeInterval)getVideoDuration:(NSURL *)videoURL{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset*urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    NSTimeInterval floatsecond = urlAsset.duration.value/ urlAsset.duration.timescale;
    return floatsecond;
}

- (CGSize)getVideoResolution:(NSURL *)videoURL {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    return videoTrack.naturalSize;
}

-(NSString *)createTmpSaveVideoPath{
    
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:TmpSaveVideoDirectory];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:NULL error:NULL];
    } else {
        if (!isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:NULL error:NULL];
        }
    }
    return outputPath;
}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger count = 1;
    if (self.taskModel.limit_of_one_upload_image > 0) {
        count ++;
    }
    return count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (![self canEdit]) {
            return self.videoList.count;
        }
        
        if (self.videoList.count == self.taskModel.limit_of_one_upload_video) {
            
            return self.videoList.count;
        }
        return self.videoList.count + 1;
    }
    
    if(section == 1){
        
        if (![self canEdit]) {
            return self.imageList.count;
        }
        
        if (self.imageList.count == self.taskModel.limit_of_one_upload_image) {
            
            return self.imageList.count;
        }
        return self.imageList.count + 1;
    }
    return 0;
    
    
}
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 36);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        MOPictureVideoStep2HeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MOPictureVideoStep2HeaderView" forIndexPath:indexPath];
        MOTaskQuestionModel *model = self.questionDetail.data[self.currentQuestionIndex];
        if (indexPath.section == 0) {
            header.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"视频（%lu/%lu）", nil),(unsigned long)self.videoList.count,self.taskModel.limit_of_one_upload_video];
            if (self.videoList.count == 0 && model.status == 0)  {
                NSString *tipStr = [NSString stringWithFormat:NSLocalizedString(@"需上传%ld个视频", nil),(long)self.taskModel.limit_of_one_upload_video];
                [header setWanringTitle:tipStr];
                header.completeBtn.hidden = NO;
            }
            if (self.videoList.count > 0 && model.status == 0) {
                NSString *tipStr = [NSString stringWithFormat:NSLocalizedString(@"需再上传%ld个视频", nil),(long)self.taskModel.limit_of_one_upload_video - self.videoList.count];
                [header setWanringTitle:tipStr];
                header.completeBtn.hidden = NO;
            }
            if (self.videoList.count == self.taskModel.limit_of_one_upload_video && model.status == 0) {
                header.completeBtn.hidden = NO;
                [header setSuccessTitle:NSLocalizedString(@"上传成功", nil)];
                
            }
        } else {
            header.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"图片（%lu/%lu）", nil),(unsigned long)self.imageList.count,self.taskModel.limit_of_one_upload_image];
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
            
            
        }
        
        return header;
    }
    
    return nil;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        if (self.videoList.count - 1 >= indexPath.item && self.videoList.count != 0) {
            MOFillTaskVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOFillTaskVideoCell" forIndexPath:indexPath];
            cell.suspendImageView.hidden = NO;
            NSInteger index = indexPath.item;
            MOAttchmentVideoFileInfoModel *model = self.videoList[index];
            cell.deleteBtn.hidden = !([self canSubmitData] && model.fileStatus == 0);
            [cell configVideoCellWithModel:model];
            cell.failurePromptView.hidden = !([self.taskModel.task_status integerValue] == 3 && model.fileStatus == 3);
            WEAKSELF
            cell.didDeleteBtnClick = ^{
                
                [[weakSelf mutableArrayValueForKey:@"videoList"] removeObjectAtIndex:index];
                [weakSelf.step2View.pictureVideoCollectionView reloadData];
            };
            cell.didErrorIconClick = ^{
                
                [weakSelf goPickVideoWithMaxCount:1 selectedAssets:@[model] complete:^(NSArray<MOAttchmentVideoFileInfoModel *> *modelList) {
                    MOAttchmentVideoFileInfoModel *replaceModel = modelList.firstObject;
                    if (!replaceModel) {
                        return;
                    }
                    replaceModel.fileId = model.fileId;
                    replaceModel.fileStatus = model.fileStatus;
                    replaceModel.errorMsg = model.errorMsg;
                    replaceModel.fileServerUrl = nil;
                    if (replaceModel) {
                        [[weakSelf mutableArrayValueForKey:@"videoList"] replaceObjectAtIndex:index withObject:replaceModel];
                        [weakSelf.step2View.pictureVideoCollectionView reloadData];
                    }
                    
                }];
            };
            
            return cell;
        }
    }
    
    if(indexPath.section == 1) {
        if (self.imageList.count - 1 >= indexPath.item && self.imageList.count != 0) {
            MOFillTaskVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOFillTaskVideoCell" forIndexPath:indexPath];
            cell.suspendImageView.hidden = NO;
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
                    if (!replaceModel) {
                        return;
                    }
                    replaceModel.fileId = model.fileId;
                    replaceModel.fileStatus = model.fileStatus;
                    replaceModel.errorMsg = model.errorMsg;
                    [[weakSelf mutableArrayValueForKeyPath:@"imageList"] replaceObjectAtIndex:indexPath.item withObject:replaceModel];
                    [weakSelf.step2View.pictureVideoCollectionView reloadData];
                }];
            
            };
            return cell;
        }
    }
    
    MOPictureVideoStep2PlaceholderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOPictureVideoStep2PlaceholderCell" forIndexPath:indexPath];
    return cell;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    MOTaskQuestionModel *questionMode = self.questionDetail.data[self.currentQuestionIndex];
    if (questionMode.status != 0) {
        NSMutableArray *dataList = @[].mutableCopy;
        if (indexPath.section == 0 ) {
            for (MOAttchmentVideoFileInfoModel *videoModel in self.videoList) {
                MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
                imageModel.type = MOBrowseMediumItemTypeVideo;
                imageModel.url = videoModel.fileServerUrl?videoModel.fileServerUrl:videoModel.locationMediaURL.absoluteString;
                [dataList addObject:imageModel];
            }
        } else {
            for (MOAttchmentImageFileInfoModel *model in self.imageList) {
                MOBrowseMediumItemModel *imageModel = [MOBrowseMediumItemModel new];
                imageModel.type = MOBrowseMediumItemTypeImage;
                imageModel.url = model.fileServerUrl;
                imageModel.image = model.image;
                [dataList addObject:imageModel];
            }
            
        }
        
        MOBrowseMediumVC *vc = [[MOBrowseMediumVC alloc] initWithDataList:dataList selectedIndex:indexPath.item];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:NULL];
        return;
    }
    
    
    if (indexPath.section == 0) {
        WEAKSELF
        [weakSelf goPickVideo];
    }
    
    if (indexPath.section == 1) {
        
        [self goPickeImages];
        
    }
    
    
}


#pragma mark - setter && getter
-(NSMutableArray<MOAttchmentImageFileInfoModel *> *)imageList {
    
    if (!_imageList) {
        _imageList = @[].mutableCopy;
    }
    return _imageList;
}


-(NSMutableArray<MOAttchmentVideoFileInfoModel *> *)videoList {
    
    if (!_videoList) {
        _videoList = @[].mutableCopy;
    }
    return _videoList;
}


@end
