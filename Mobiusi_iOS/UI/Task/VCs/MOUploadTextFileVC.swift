//
//  MOUploadTextFileVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/8.
//

import Foundation

@objc public class MOUploadTextFileVC: MOBaseViewController {
    
    var fileData:MOAttchmentFileInfoModel?
    var location:String?
    lazy var nextBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("下一步", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(12))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        btn.fixAlignmentBUG()
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return btn
    }()
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("", comment: "")
        
        navBar.backBtn.fixAlignmentBUG()
        navBar.backBtn.setImage(UIImage())
        navBar.backBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        navBar.backBtn.setTitle(NSLocalizedString("取消", comment: ""), titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))

        return navBar
    }();
    
    lazy var topContentView:MOView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    
    lazy var textView:UITextView = {
        let tv = UITextView()
        tv.textColor = BlackColor
        tv.font = MOPingFangSCMediumFont(12)
        tv.zw_placeHolder = NSLocalizedString("这一刻的想法...", comment: "")
        return tv
    }()
    
    lazy var textFileCollectionView:UICollectionView = {
        let fllowLayout = UICollectionViewFlowLayout()
        fllowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView.init(frame: CGRect(), collectionViewLayout: fllowLayout)
        collectionView.register(MOTextFillTaskUploadFileCell.self, forCellWithReuseIdentifier: "MOTextFillTaskUploadFileCell")
        collectionView.register(MOTextFillTaskUploadPlaceholderCell.self, forCellWithReuseIdentifier: "MOTextFillTaskUploadPlaceholderCell")
        return collectionView
    }()
    
    lazy var locateView:MOPositionInformationView = {
        let vi = MOPositionInformationView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    
    
    func setupUI(){
        navBar.gobackDidClick = {[weak self] in
            guard let self else {return}
            self.dismiss(animated: true)
        }
        navBar.rightItemsView.addArrangedSubview(self.nextBtn)
        view.addSubview(navBar)
        view.addSubview(topContentView)
        topContentView.addSubview(textView)
        textFileCollectionView.delegate = self
        textFileCollectionView.dataSource = self
        topContentView.addSubview(textFileCollectionView)
        view.addSubview(locateView)
    }
    
    func setupConstraints(){
        
        self.nextBtn.snp.makeConstraints { make in
            make.height.equalTo(26)
        }
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        topContentView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(289)
        }
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-19)
            make.top.equalToSuperview().offset(12)
        }
        
        textFileCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(textView.snp.bottom).offset(-10)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }
        
        
        locateView.snp.makeConstraints { make in
            make.top.equalTo(topContentView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.height.equalTo(55)
        }
    }
    
    func addActions(){
        
        self.nextBtn.addTarget(self, action: #selector(nextBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func nextBtnClick(){
        uploadFile()
    }
    
    func uploadFile(){
        
        
        guard let fileData else {
            self.showMessage(NSLocalizedString("请上传一个文件", comment: ""))
            return
        }
        
        let idea = textView.text
        nonisolated(unsafe) var uploadFail = false
        self.showActivityIndicator()
        
        let taskGroup = DispatchGroup()
        let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
        taskGroup.enter()
        let mineType = NSString.mimeType(forExtension: fileData.fileExtension)
        queue.async(group: taskGroup,execute: {
            
            MONetDataServer.shared().uploadFile(withFileName: fileData.fileName, fileData: fileData.fileData, mimeType: mineType) {dict in
                
                fileData.fileServerUrl = dict?["url"] as? String
                fileData.fileServerRelativeUrl = dict?["relative_url"] as? String
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
            let  user_data = MOUploadFileDataModel()
            user_data.file_name = fileData.fileName
            user_data.size = fileData.fileData?.count ?? 0
            user_data.format = fileData.fileExtension
            user_data.url = fileData.fileServerRelativeUrl
            let user_datas = NSArray(object: user_data)
            let userDataStr = user_datas.yy_modelToJSONString()
            
            MONetDataServer.shared().unlimitedUploadData(withCateId: 3, idea:idea, location: self.location, user_data: userDataStr,content_id: 0,is_summarize: false) {
                
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
    
    @objc public class func createAlertStyle() ->MOUploadTextFileVC{
        let vc = MOUploadTextFileVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    public override func viewDidLoad() {
    super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
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
}

extension MOUploadTextFileVC:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.bounds.width
            // 如果有边距，需要减去边距
            DLog("collectionView.bounds.width:\(width)")
            let insets = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
            let availableWidth = width - insets.left - insets.right
            return CGSize(width: availableWidth, height: 35)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if fileData != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOTextFillTaskUploadFileCell", for: indexPath)
            if let cell1 = cell as? MOTextFillTaskUploadFileCell,let model = fileData {
                cell1.configCell(with:model)
                cell1.didDeleteBtnClick = {[weak self] in
                    guard let self else {return}
                    fileData = nil
                    textFileCollectionView.reloadData()
                }
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOTextFillTaskUploadPlaceholderCell", for: indexPath)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if fileData != nil {
            return
        }
        let allowedTypes = ["com.microsoft.word.doc","com.microsoft.word.docx","public.content"]
        let documentPicker = UIDocumentPickerViewController.init(documentTypes: allowedTypes, in: UIDocumentPickerMode.import)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overFullScreen
        documentPicker.modalTransitionStyle = .crossDissolve
        self.present(documentPicker, animated: true)
    }
}


extension MOUploadTextFileVC:UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileAttchModel = MOAttchmentFileInfoModel()
        fileAttchModel.fileExtension = url.pathExtension
        fileAttchModel.fileName = url.lastPathComponent
        fileAttchModel.fileData = try? Data(contentsOf: url)
        fileData = fileAttchModel
        DLog("\(url)")
        controller.dismiss(animated: true)
        textFileCollectionView.reloadData()
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true)
    }
}
