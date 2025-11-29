//
//  MOAlbumOperationTopicVC.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import "MOAlbumOperationTopicVC.h"

@interface MOAlbumOperationTopicVC ()

@end

@implementation MOAlbumOperationTopicVC
@synthesize step2View = _step2View;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)configUIAfterReceivingData {
    [super configUIAfterReceivingData];
    WEAKSELF
    self.step2View.exampleBtn.hidden = [self.taskModel.example_url length] == 0;
    self.step2View.didExampleBtnClick = ^{
        [MOWebViewController pushWebVCWithUrl:weakSelf.taskModel.example_url title:NSLocalizedString(@"样例", nil)];
    };
    [self.scrollContentView addSubview:self.step2View];
    self.step2View.pictureVideoCollectionView.delegate = self;
    self.step2View.pictureVideoCollectionView.dataSource = self;
    [self.step2View.pictureVideoCollectionView registerClass:[MOPictureVideoStep2PlaceholderCell class] forCellWithReuseIdentifier:@"MOPictureVideoStep2PlaceholderCell"];
    [self.step2View.pictureVideoCollectionView registerClass:[MOFillTaskVideoCell class] forCellWithReuseIdentifier:@"MOFillTaskVideoCell"];
    [self.step2View.pictureVideoCollectionView registerClass:[MOPictureVideoStep2HeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MOPictureVideoStep2HeaderView"];
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 0;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 0;
}
- (CGSize)collectionView:(UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 36);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        MOPictureVideoStep2HeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MOPictureVideoStep2HeaderView" forIndexPath:indexPath];
        header.titleLabel.text = @"视频（1/1）";
        return header;
    }
    
    return nil;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MOPictureVideoStep2PlaceholderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MOPictureVideoStep2PlaceholderCell" forIndexPath:indexPath];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.delegate = vc;
    if (indexPath.section == 0) {
        vc.mediaTypes = @[(NSString *)kUTTypeMovie];
        vc.didFinishPickingMediaWithInfo = ^(UIImagePickerController * _Nonnull imagePicker, NSDictionary<UIImagePickerControllerInfoKey,id> * _Nonnull Info) {
            
            DLog(@"%@",Info);
        };
    } else {
        vc.mediaTypes = @[(NSString *)kUTTypeImage];
    }
    [self presentViewController:vc animated:YES completion:NULL];
    
}






-(MOPictureVideoFillTaskStep2View *)step2View {
    
    if (!_step2View) {
        _step2View = [MOPictureVideoFillTaskStep2View new];
    }
    
    return _step2View;
}



@end
