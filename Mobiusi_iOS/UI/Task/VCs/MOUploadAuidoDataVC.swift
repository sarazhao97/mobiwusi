//
//  MOUploadAuidoDataVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/7.
//

import Foundation
class MOUploadAuidoDataVC: MOBaseViewController {
    
    var audioUrl:URL
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
    
    lazy var playRecordView:MOPlayRecordingView = {
        let palyerView = MOPlayRecordingView()
        palyerView.backgroundColor = ColorEDEEF5
        palyerView.cornerRadius(QYCornerRadius.all, radius: 10)
        return palyerView
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
            self.playRecordView.timer?.invalidate()
            self.playRecordView.timer = nil
            self.dismiss(animated: true)
        }
        navBar.rightItemsView.addArrangedSubview(self.nextBtn)
        view.addSubview(navBar)
        view.addSubview(topContentView)
        topContentView.addSubview(textView)
        topContentView.addSubview(playRecordView)
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
        
        playRecordView.snp.makeConstraints { make in
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
        
        let idea = textView.text
        nonisolated(unsafe) var uploadFail = false
        nonisolated(unsafe) var fileServerUrl:String?
        nonisolated(unsafe) var fileServerRelativeUrl:String?
        let fileName = audioUrl.lastPathComponent
        let filePath = audioUrl.relativePath
        
        self.showActivityIndicator()
        
        let taskGroup = DispatchGroup()
        let queue = DispatchQueue(label: "upload",attributes: DispatchQueue.Attributes.concurrent)
        
        taskGroup.enter()
        queue.async(group: taskGroup,execute: {
            
            MONetDataServer.shared().uploadAudioFile(withFileName: fileName, filePath: filePath) { dict in
                
                fileServerUrl = dict?["url"] as? String
                fileServerRelativeUrl = dict?["relative_url"] as? String
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
            let data = try? Data(contentsOf: self.audioUrl)
            let duration = 1000 * (self.playRecordView.audioPalyer?.duration ?? 0)
            let audio_dict = [
                "file_name":fileName,
                "duration":duration as Any,
                "format":"WAV",
                "size":data?.count as Any,
                "url":fileServerRelativeUrl as Any,
                "rate":"44100"
            ] as? NSDictionary
            let user_datas = NSArray(object: audio_dict as Any)
            let userDataStr = user_datas.yy_modelToJSONString()
            
            MONetDataServer.shared().unlimitedUploadData(withCateId: 1, idea:idea, location: self.location, user_data: userDataStr,content_id: 0,is_summarize: false) {
                
                self.hidenActivityIndicator()
                self.showMessage(NSLocalizedString("上传成功", comment: ""))
                self.playRecordView.timer?.invalidate()
                self.playRecordView.timer = nil
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
    
    @objc public class func createAlertStyle(audioUrl:URL) ->MOUploadAuidoDataVC{
        let vc = MOUploadAuidoDataVC(audioUrl:audioUrl)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    init(audioUrl:URL){
        self.audioUrl = audioUrl
        super.init(nibName: nil, bundle: nil)
        self.playRecordView.setAudioPath(url: audioUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
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
