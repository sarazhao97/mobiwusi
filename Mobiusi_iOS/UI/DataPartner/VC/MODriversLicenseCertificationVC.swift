//
//  MODriversLicenseCertificationVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/28.
//

import Foundation

class MODriversLicenseCertificationVC: MOBaseViewController {
    
    var didUploadSuccess:(()->Void)?
    var frontOfDriverLicense:MOAttchmentImageFileInfoModel?
    var backOfDriverLicense:MOAttchmentImageFileInfoModel?
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("认证", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
        return navBar
    }();
    var scrollView:UIScrollView = {
        
        let scrollView = UIScrollView()
        return scrollView;
    }()
    
    var scrollViewContent:MOView = {
        
        let vi = MOView()
        return vi;
    }()
    
    
    var step1View:MOUploadImageView = {
        let vi = MOUploadImageView(title: NSLocalizedString("第1步：请拍摄您的驾驶证主页", comment: ""), subTitle: NSLocalizedString("请确保证件边框完整、字体清晰、亮度均匀", comment: ""), bgimageName: "icon_driver_licence_main")
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    var step2View:MOUploadImageView = {
        let vi = MOUploadImageView(title: NSLocalizedString("第2步：请拍摄您的驾驶证副页", comment: ""), subTitle: NSLocalizedString("请确保证件边框完整、字体清晰、亮度均匀", comment: ""), bgimageName: "icon_driver_licence_deputy")
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    var bottomBtn:MOBtnWithTopTitleView = {
        
        let btn = MOBtnWithTopTitleView()
        return btn
    }()
    
    
    func setupUI(){
        
        navBar.gobackDidClick = {
            MOAppDelegate().transition.popViewController(animated: true)
        }
        view.addSubview(navBar)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContent)
        step1View.didClick = {[weak self] in
            guard let self else {return}
            self.pickerPicture(isFornt: true)
        }
        scrollViewContent.addSubview(step1View)
        step2View.didClick = {[weak self] in
            guard let self else {return}
            self.pickerPicture(isFornt: false)
        }
        scrollViewContent.addSubview(step2View)
        bottomBtn.didCick = {[weak self] in
            self?.uploadImage()
        }
        view.addSubview(bottomBtn)
    }
    
    func setupConstraints(){
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(scrollView.snp.bottom)
            make.bottom.equalToSuperview()
            
        }
        
        
        scrollViewContent.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        
        step1View.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview()
        }
        
        step2View.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(step1View.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
    }
    
    private func pickerPicture(isFornt:Bool){
        let imagePickerVC = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
        guard let imagePickerVC else {return}
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.showSelectBtn = true
        imagePickerVC.showSelectedIndex = true
        let licenseModel = isFornt ? frontOfDriverLicense:backOfDriverLicense
        if (licenseModel != nil) {
            imagePickerVC.selectedAssets = [licenseModel?.imageAsset as Any]
        }
        
        
        imagePickerVC.modalPresentationStyle = .overFullScreen
        imagePickerVC.modalTransitionStyle = .coverVertical
        imagePickerVC.didFinishPickingPhotosHandle = {[weak self] (photos,assets,isSelectOriginalPhoto) in
            guard let self else {return}
            let model = MOAttchmentImageFileInfoModel()
            if let itemImage = photos?.first {
                model.image = itemImage
                model.quality = "\(Int(itemImage.size.width))x\(Int(itemImage.size.height))"
            }
            if let imageAsset = assets?.first as? PHAsset {
                let format = imageAsset.getFormat()
                model.imageAsset = imageAsset
                model.fileName = "\(NSUUID().uuidString).\(format)"
                model.fileExtension = format
                model.location = "\(String(describing: imageAsset.location?.coordinate.latitude)),\(String(describing: imageAsset.location?.coordinate.longitude))"
            }
            if isFornt {
                frontOfDriverLicense = model
            } else {
                backOfDriverLicense = model
            }
            let targetView = isFornt ? step1View:step2View
            if let image =  photos?.first {
                targetView.configImage(selectedImage: image)
            }
        }
        self.present(imagePickerVC, animated: true)
    }
    
    func uploadImage(){
        
        guard let frontOfDriverLicense else {
            showMessage(NSLocalizedString("请拍摄您的驾驶证主页", comment: ""))
            return
        }
        
        guard let backOfDriverLicense else {
            showMessage(NSLocalizedString("请拍摄您的驾驶证副页", comment: ""))
            return
        }
        
        let taskGroup = DispatchGroup()
        let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
        nonisolated(unsafe) var uploadFail = false
        showActivityIndicator()
        taskGroup.enter()
        queue.async(group: taskGroup,execute: {
            
            var mineType = "image/png"
            if frontOfDriverLicense.fileExtension.lowercased() == "png" {
                frontOfDriverLicense.fileData = frontOfDriverLicense.image?.pngData()
            }
            
            if frontOfDriverLicense.fileData == nil {
                mineType = "image/jpeg"
                frontOfDriverLicense.fileData = frontOfDriverLicense.image?.jpegData(compressionQuality: 1.0)
            }
            
            MONetDataServer.shared().uploadFile(withFileName: frontOfDriverLicense.fileName, fileData: frontOfDriverLicense.fileData, mimeType: mineType) {dict in
                
                frontOfDriverLicense.fileServerUrl = dict?["url"] as? String
                frontOfDriverLicense.fileServerRelativeUrl = dict?["relative_url"] as? String
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
        
        
        taskGroup.enter()
        queue.async(group: taskGroup,execute: {
            
            var mineType = "image/png"
            if backOfDriverLicense.fileExtension.lowercased() == "png" {
                backOfDriverLicense.fileData = backOfDriverLicense.image?.pngData()
            }
            
            if backOfDriverLicense.fileData == nil {
                mineType = "image/jpeg"
                backOfDriverLicense.fileData = backOfDriverLicense.image?.jpegData(compressionQuality: 1.0)
            }
            
            MONetDataServer.shared().uploadFile(withFileName: backOfDriverLicense.fileName, fileData: backOfDriverLicense.fileData, mimeType: mineType) {dict in
                
                backOfDriverLicense.fileServerUrl = dict?["url"] as? String
                backOfDriverLicense.fileServerRelativeUrl = dict?["relative_url"] as? String
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
                self.showErrorMessage(NSLocalizedString("上传失败", comment: ""))
                return
            }
            
            MONetDataServer.shared().saveAuth(withAuthType: 2, identityCardFront: nil, identityCardBack: nil, driverLicenceMain: frontOfDriverLicense.fileServerRelativeUrl, driverLicenceDeputy: backOfDriverLicense.fileServerRelativeUrl, workCompany: nil, workIncome: 0, educationImage: nil, workType: 0) { dic in
                self.hidenActivityIndicator()
                self.showMessage(NSLocalizedString("上传成功", comment: ""))
                self.didUploadSuccess?()
                MOAppDelegate().transition.popViewController(animated: true)
                
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
    }
}
