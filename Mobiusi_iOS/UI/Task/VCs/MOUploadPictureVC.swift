//
//  MOUploadPictureVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/8.
//

import Foundation
class MOUploadPictureVC: MOUploadAlbumVC {
    
    var pictureList:[MOAttchmentImageFileInfoModel] = []
    var location:String?
    private func pickerPicture(){
        let imagePickerVC = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
        guard let imagePickerVC else {return}
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.showSelectBtn = true
        imagePickerVC.showSelectedIndex = true
        if (pictureList.first != nil) {
            imagePickerVC.selectedAssets = [pictureList.first?.imageAsset as Any]
        }
        
        imagePickerVC.modalPresentationStyle = .overFullScreen
        imagePickerVC.modalTransitionStyle = .coverVertical
        
        
        imagePickerVC.didFinishPickingPhotosHandle = {[weak self] (photos,assets,isSelectOriginalPhoto) in
            guard let self else {return}
            let model = MOAttchmentImageFileInfoModel()
            model.image = photos?.first
            if let imageAsset = assets?.first as? PHAsset {
                
                model.imageAsset = imageAsset
                let fileExtension = imageAsset.getFormat()
                model.fileName = "\(UUID().uuidString).\(fileExtension)";
                model.fileExtension = fileExtension
            }
            
            
            pictureList.removeAll()
            pictureList.append(model)
            albumCollectionView.reloadData()
            
        }
        self.present(imagePickerVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOLocationManager.shared.onCityUpdate = {[weak self]city,success in
            
            guard let city else {return}
            guard let self else {return}
			if success {
				locateView.locateNameLabel.text = city
				location = city
				DLog("\(String(describing: city))")
			}
        }
        MOLocationManager.shared.startUpdatingLocation()
    }
    
    @objc override func nextBtnClick(){
        
        uploadFile()
    }
    
    func uploadFile(){
        
        guard let picture = pictureList.first else {
            self.showMessage(NSLocalizedString("请上传一个文件", comment: ""))
            return
        }
        
        let idea = textView.text
        nonisolated(unsafe) var uploadFail = false
        self.showActivityIndicator()
        
        let taskGroup = DispatchGroup()
        let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
        taskGroup.enter()
        let mineType = NSString.mimeType(forExtension: picture.fileExtension)
        queue.async(group: taskGroup,execute: {[weak picture] in
            guard let picture else {return}
            TZImageManager.default().requestImageData(for: picture.imageAsset) {[weak picture] data, dataUTI, orientation, _ in
                
                guard let picture else {return}
                picture.fileData = data
                
                if data == nil {
                    uploadFail = true
                    taskGroup.leave()
                    return
                }
                MONetDataServer.shared().uploadFile(withFileName: picture.fileName, fileData: picture.fileData, mimeType: mineType) {dict in
                    
                    picture.fileServerUrl = dict?["url"] as? String
                    picture.fileServerRelativeUrl = dict?["relative_url"] as? String
                    taskGroup.leave()
                    
                } failure: { error in
                    uploadFail = true
                    taskGroup.leave()
                } loginFail: {
					DispatchQueue.main.async {
						self.hidenActivityIndicator()
					}
                    uploadFail = true
                    taskGroup.leave()
                }
                
            } progressHandler: { _, _, _, _ in
                
            }

        });
        
        taskGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            
            if uploadFail {
                self.hidenActivityIndicator()
                self.showErrorMessage(NSLocalizedString("上传失败或者格式不支持", comment: ""))
                return
            }
            let  user_data = MOUploadPictureFileDataModel()
            user_data.file_name = picture.fileName
            user_data.size = picture.fileData?.count ?? 0
            user_data.format = picture.fileExtension
            user_data.url = picture.fileServerRelativeUrl
            if let image = picture.image {
                user_data.quality = "\(image.size.width)x\(image.size.height)"
            }
            user_data.location = picture.location
            let user_datas = NSArray(object: user_data)
            let userDataStr = user_datas.yy_modelToJSONString()
            
            MONetDataServer.shared().unlimitedUploadData(withCateId: 2, idea:idea, location: self.location, user_data: userDataStr,content_id: 0,is_summarize: false) {
                
                self.hidenActivityIndicator()
                self.showMessage(NSLocalizedString("上传成功", comment: ""))
                self.dismiss(animated: true)
				NotificationCenter.default.post(name: .UnlimitedUploadDataUploadSuccess, object: nil)
                
            } failure: { error in
                self.hidenActivityIndicator()
                guard let error else {return}
                self.showErrorMessage(error.localizedDescription)
            } msg: { msg in
                self.hidenActivityIndicator()
                guard let msg else {return}
                self.showErrorMessage(msg)
            } loginFail: {
                self.hidenActivityIndicator()
            }
        }))
    }
    
    
    @objc public override class func createAlertStyle() ->MOUploadPictureVC{
        let vc = MOUploadPictureVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if pictureList.count > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOFillTaskVideoCell", for: indexPath)
            if let cell1 = cell as? MOFillTaskVideoCell,let model = pictureList.first {
                cell1.configImageCell(with: model)
                cell1.didDeleteBtnClick = {[weak self] in
                    guard let self else {return}
                    pictureList.removeAll()
                    albumCollectionView.reloadData()
                }
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOPictureVideoStep2PlaceholderCell", for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if pictureList.count > 0{
            let model = MOBrowseMediumItemModel()
            model.type = MOBrowseMediumItemType.init(rawValue: 0)
            model.image = pictureList.first?.image
            let vc = MOBrowseMediumVC.init(dataList: [model], selectedIndex: 0)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
            return
        }
        pickerPicture()
        
    }
}
