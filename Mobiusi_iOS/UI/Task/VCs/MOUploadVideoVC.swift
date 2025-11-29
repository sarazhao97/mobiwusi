//
//  MOUploadVideoVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/8.
//

import Foundation
class MOUploadVideoVC: MOUploadAlbumVC {
    
    var videoList:[MOAttchmentVideoFileInfoModel] = []
    var location:String?
    
    
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
    private func pickerVideo(){
        let imagePickerVC = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
        guard let imagePickerVC else {return}
        imagePickerVC.allowPickingImage = false
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.showSelectedIndex = true
        imagePickerVC.showSelectBtn = true
        imagePickerVC.allowPickingVideo = true
        imagePickerVC.showSelectedIndex = true
        imagePickerVC.allowPickingMultipleVideo = true
        if (videoList.first != nil) {
            imagePickerVC.selectedAssets = [videoList.first?.videoAsset as Any]
        }
        
        imagePickerVC.modalPresentationStyle = .overFullScreen
        imagePickerVC.modalTransitionStyle = .coverVertical
        imagePickerVC.uiImagePickerControllerSettingBlock = {imagePickerController in
            
            guard let imagePickerController else {return}
            imagePickerController.videoQuality = .typeHigh
        }
        imagePickerVC.didFinishPickingVideoHandle = {[weak self](coverImage,asset) in
            
            DLog("\(String(describing: asset))")
            guard let asset  else {return}
            guard let self else { return}
            self.showActivityIndicator()
            asset.proccessVideo { [weak self, asset](outputURL,sucess) in
                guard let self else {return}
                self.hidenActivityIndicator()
                if sucess {
                    let model = self.createVideo(videoURL: outputURL)
                    model.videoAsset = asset
                    model.locationMediaURL = outputURL
                    videoList.removeAll()
                    videoList.append(model)
                    albumCollectionView.reloadData()
                    
                } else {
                    self.showMessage(NSLocalizedString("导出失败", comment: ""))
                }
            }
        }
        self.present(imagePickerVC, animated: true)
    }
    
    
    func uploadFile(){
        
        let videoData = videoList.first
        guard let videoData else {
            self.showMessage(NSLocalizedString("请上传一个文件", comment: ""))
            return
        }
        
        let idea = textView.text
        nonisolated(unsafe) var uploadFail = false
        self.showActivityIndicator()
        
        let taskGroup = DispatchGroup()
        let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
        taskGroup.enter()
        let mineType = NSString.mimeType(forExtension: videoData.fileExtension)
        queue.async(group: taskGroup,execute: {
            
            MONetDataServer.shared().uploadFile(withFileName: videoData.fileName, fileData: videoData.fileData, mimeType: mineType) {dict in
                
                videoData.fileServerUrl = dict?["url"] as? String
                videoData.fileServerRelativeUrl = dict?["relative_url"] as? String
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
            
        });
        
        taskGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            
            if uploadFail {
                self.hidenActivityIndicator()
                self.showErrorMessage(NSLocalizedString("上传失败或者格式不支持", comment: ""))
                return
            }
            let  user_data = MOUploadVideoFileDataModel()
            user_data.file_name = videoData.fileName
            user_data.size = videoData.fileData?.count ?? 0
            user_data.format = videoData.fileExtension
            user_data.url = videoData.fileServerRelativeUrl
            user_data.quality = videoData.quality
            user_data.duration = videoData.duration
            let user_datas = NSArray(object: user_data)
            let userDataStr = user_datas.yy_modelToJSONString()
            
            MONetDataServer.shared().unlimitedUploadData(withCateId: 4, idea:idea, location: self.location, user_data: userDataStr,content_id: 0, is_summarize: false) {
                
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
    
    func createVideo(videoURL:URL) ->MOAttchmentVideoFileInfoModel{
        let videoAsset =  AVURLAsset.createVideoAsset(with: videoURL)
        
        let model = MOAttchmentVideoFileInfoModel()
        model.fileData = try? Data(contentsOf: videoURL)
        model.fileExtension = videoURL.pathExtension
        model.fileName = videoURL.lastPathComponent
        model.thumbnail = videoAsset.getVideoThumbnail()
        model.duration = Int(videoAsset.getVideoDuration() * 1000)
        return model
    }
    
    override func nextBtnClick() {
        uploadFile()
    }
    
    @objc public override class func createAlertStyle() ->MOUploadVideoVC{
        let vc = MOUploadVideoVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if videoList.count > 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOFillTaskVideoCell", for: indexPath)
            if let cell1 = cell as? MOFillTaskVideoCell,let model = videoList.first {
                cell1.configVideoCell(with: model)
                cell1.failurePromptView.isHidden = true
                cell1.didDeleteBtnClick = {[weak self] in
                    guard let self else {return}
                    videoList.removeAll()
                    albumCollectionView.reloadData()
                }
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOPictureVideoStep2PlaceholderCell", for: indexPath)
        return cell
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if videoList.count > 0{
            let model = MOBrowseMediumItemModel()
            model.type = MOBrowseMediumItemType.init(rawValue: 1)
            model.url = videoList.first?.locationMediaURL.absoluteString
            let vc = MOBrowseMediumVC.init(dataList: [model], selectedIndex: 0)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
            return
        }
        pickerVideo()
        
    }
}
