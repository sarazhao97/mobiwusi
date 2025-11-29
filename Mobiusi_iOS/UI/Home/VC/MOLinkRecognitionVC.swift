//
//  MOLinkRecognitionVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
import UIKit
import AVFoundation

class MOLinkRecognitionVC: MOBaseViewController {

    @objc public init(linkStr: String = "", fromPasteboard: Bool = false, needToInput: Bool = false) {
        self.linkStr = linkStr
        self.formPasteboard = fromPasteboard
        self.needToInput = needToInput
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var linkStr:String
    var formPasteboard:Bool = true
	var needToInput = false
    var dataModel:MOParsePasteboardContentModel?
    var islocalFile = false
    var videoThumbnailPath:String?
    
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("链接识别", comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }()
	
	lazy var textInputView = {
		let vi  = MOLinkRecognitionInputView()
		vi.isHidden = true
		return vi
	}()
    
    lazy var scrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    lazy var contentView = {
        let vi = MOView()
        return vi
    }()
    
    lazy var bottomView = {
        let vi = MOLinkRecognitionBottomView()
//        vi.backgroundColor = WhiteColor
//        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    
    lazy var topView = {
        let vi = MOLinkRecognitionTopView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    
    lazy var typeView = {
        let vi = MOLinkRecognitionTypeView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        return vi
    }()
    

	
	lazy var recognitionFailView = {
		let vi = MOLinkRecognitionFailView()
		return vi
	}()
    
    

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.width.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)

        if self.dataModel?.status == 2 {
            setupFailUI()
        } else {
            setupSuccessUI()
        }
    }

    private func setupConstraints() {
        setupCommonConstraints()
    }

    private func setupSuccessUI() {
        contentView.addSubview(typeView)
        
        typeView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.left.right.equalTo(topView)
        }
        
        bottomView.snp.remakeConstraints { make in
            make.top.equalTo(typeView.snp.bottom).offset(33)
            make.left.right.equalTo(topView)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupFailUI() {
        contentView.addSubview(recognitionFailView)
        recognitionFailView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(54)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupCommonConstraints() {
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        topView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.top.equalToSuperview().offset(10)
        }

//        bottomView.snp.makeConstraints { make in
//            make.top.equalTo(topView.snp.bottom).offset(20)
//            make.left.right.equalTo(topView)
//            make.bottom.equalToSuperview().offset(-20)
//        }
    }


	private func findAndPopToVC<T: UIViewController>(type: T.Type, notificationName: NSNotification.Name?, createVC: @autoclosure () -> T) {
		let transition = MOAppDelegate().transition!
		if let existingVC = transition.navigationChildViewControllers().first(where: { $0 is T }) {
			if let notificationName = notificationName {
				NotificationCenter.default.post(name: notificationName, object: nil)
			}
			transition.pop(to: existingVC, animated: true)
		} else {
			let newVC = createVC()
			let currentCount = transition.navigationVCViewControllersCount()
			transition.insertVC(newVC, index: currentCount - 1)
			CATransaction.begin()
			transition.pop(to: newVC, animated: true)
			CATransaction.commit()
		}
	}

	func goBackDataVC(is_summarize: Bool) {
		if is_summarize {
			findAndPopToVC(type: MOSummarizeSampleVC.self, notificationName: .SummarizeSampleNeedRefresh, createVC: MOSummarizeSampleVC())
		} else {
			findAndPopToVC(type: MOMyAllDataVC.self, notificationName: .UnlimitedUploadDataUploadSuccess, createVC: MOMyAllDataVC(cate: 0, userTaskId: 0, user_paste_board: false))
		}
	}
    
    func addAction(){
        bottomView.summarizeBtn.addTarget(self, action: #selector(summarizeBtnClick), for: UIControl.Event.touchUpInside)
        bottomView.leavBtn.addTarget(self, action: #selector(leavBtnClick), for: UIControl.Event.touchUpInside)
    }
    private func handleUpload(isSummarize: Bool) {
        if islocalFile {
            uploadFile(is_summarize: isSummarize)
            return
        }
        
        if self.dataModel?.cate == 3, let extract_content = self.dataModel?.extract_content, !extract_content.isEmpty {
            uploadMemoryText(is_summarize: isSummarize)
        } else {
            writePasteboardContent(contentID: dataModel?.model_id ?? 0, isSummarize: isSummarize)
        }
    }
    
    @objc func summarizeBtnClick() {
        handleUpload(isSummarize: true)
    }
    
    func createVideo(videoURL:URL) ->MOAttchmentVideoFileInfoModel{
        let videoAsset =  AVURLAsset.createVideoAsset(with: videoURL)
        
        let model = MOAttchmentVideoFileInfoModel()
        model.fileData = try? Data(contentsOf: videoURL)
        model.fileExtension = videoURL.pathExtension
        model.fileName = videoURL.lastPathComponent
        model.thumbnail = videoAsset.getVideoThumbnail()
        model.duration = Int(videoAsset.getVideoDuration() * 1000)
        model.quality = String(format: "%.0fx%.0f", videoAsset.getVideoResolution().width,videoAsset.getVideoResolution().height)
        return model
    }
	
	func createAudio(audio:URL) ->MOAttchmentAudioFileInfoModel{
		let videoAsset =  AVURLAsset.createVideoAsset(with: audio)
		
		let model = MOAttchmentAudioFileInfoModel()
		model.fileData = try? Data(contentsOf: audio)
		model.fileExtension = audio.pathExtension
		model.fileName = audio.lastPathComponent
		let audiaoAsset = AVAsset(url: audio)
		model.duration = Int(CMTimeGetSeconds(audiaoAsset.duration) * 1000)
		return model
	}
    
    private func uploadData(fileName: String, fileData: Data?, mimeType: String, isSummarize: Bool, userDatas:NSArray) {
        self.showActivityIndicator()
        
        MONetDataServer.shared().uploadFile(withFileName: fileName, fileData: fileData, mimeType: mimeType) { [weak self] dict in
            guard let self = self else { return }
            
            let fileServerRelativeUrl = dict?["relative_url"] as? String
            if let fileModel = userDatas.firstObject as? MOUploadFileDataModel {
                fileModel.url = fileServerRelativeUrl
            }
            
            let userDataStr = userDatas.yy_modelToJSONString()
            
            MONetDataServer.shared().unlimitedUploadData(withCateId: self.dataModel?.cate ?? 0, idea: "", location: "", user_data: userDataStr, content_id: self.dataModel?.model_id ?? 0, is_summarize: isSummarize) { [weak self] in
                guard let self = self else { return }
                self.hidenActivityIndicator()
                self.showMessage(NSLocalizedString("上传成功", comment: ""))
                // 上传成功后：发送刷新通知并执行统一返回逻辑
                if isSummarize {
                    NotificationCenter.default.post(name: .SummarizeSampleNeedRefresh, object: nil)
                } else {
                    NotificationCenter.default.post(name: .UnlimitedUploadDataUploadSuccess, object: nil)
                }
                self.performBackAction()
            } failure: { [weak self] error in
                self?.hidenActivityIndicator()
                self?.showErrorMessage(error?.localizedDescription)
            } msg: { [weak self] msg in
                self?.hidenActivityIndicator()
                self?.showErrorMessage(msg)
            } loginFail: { [weak self] in
                self?.hidenActivityIndicator()
            }
        } failure: { [weak self] error in
            self?.hidenActivityIndicator()
            self?.showErrorMessage(error?.localizedDescription)
        } loginFail: { [weak self] in
            self?.hidenActivityIndicator()
        }
    }
    
    func uploadMemoryText(is_summarize: Bool) {
        let fileName = String(format: "%@.txt", self.dataModel?.title ?? "")
        let fileData = self.dataModel?.extract_content?.data(using: .utf8, allowLossyConversion: true)
        
        let user_data = MOUploadFileDataModel()
        user_data.file_name = fileName
        user_data.size = fileData?.count ?? 0
        user_data.format = "txt"
        
        uploadData(fileName: fileName, fileData: fileData, mimeType: "text/plain", isSummarize: is_summarize, userDatas: NSArray(object: user_data))
    }
    
    func uploadFile(is_summarize: Bool) {
        guard let path = URL(string: linkStr) else { return }
        let fileExtension = path.pathExtension.lowercased()
        let fileName = path.lastPathComponent
        let mimeType = NSString.mimeType(forExtension: fileExtension)
        let fileData = try? Data(contentsOf: path)
        
        let user_datas: NSMutableArray = []
		if self.dataModel?.cate == 1 {
			let audiaoModel = createAudio(audio: path)
			let user_data = MOUploadAudioFileDataModel()
			user_data.file_name = audiaoModel.fileName
			user_data.size = audiaoModel.fileData?.count ?? 0
			user_data.format = audiaoModel.fileExtension
			user_data.duration = audiaoModel.duration
			user_datas.add(user_data)
		} else if self.dataModel?.cate == 2 {
            let user_data = MOUploadPictureFileDataModel()
            user_data.file_name = fileName
            user_data.size = fileData?.count ?? 0
            user_data.format = fileExtension
            if let fileData, let image = UIImage(data: fileData) {
                user_data.quality = "\(image.size.width)x\(image.size.height)"
            }
            user_datas.add(user_data)
        } else if self.dataModel?.cate == 4 {
            let videoModel = createVideo(videoURL: path)
            let user_data = MOUploadVideoFileDataModel()
            user_data.file_name = videoModel.fileName
            user_data.size = videoModel.fileData?.count ?? 0
            user_data.format = videoModel.fileExtension
            user_data.quality = videoModel.quality
            user_data.duration = videoModel.duration
            user_datas.add(user_data)
        }
        
        uploadData(fileName: fileName, fileData: fileData, mimeType: mimeType, isSummarize: is_summarize, userDatas: user_datas)
    }
    
    func writePasteboardContent(contentID: Int = 0, isSummarize: Bool = true) {
        self.showActivityIndicator()
        MONetDataServer.shared().writePasteboardContentWithcontentId(contentID, isSummarize: isSummarize) { [weak self] in
            guard let self = self else { return }
            self.hidenActivityIndicator()
            self.showMessage(NSLocalizedString("上传成功", comment: ""))
            // 上传成功后：发送刷新通知并执行统一返回逻辑
            if isSummarize {
                NotificationCenter.default.post(name: .SummarizeSampleNeedRefresh, object: nil)
            } else {
                NotificationCenter.default.post(name: .UnlimitedUploadDataUploadSuccess, object: nil)
            }
            self.performBackAction()
        } failure: { [weak self] error in
            self?.handleRequestFailure(error: error)
        } msg: { [weak self] msg in
            self?.handleRequestFailure(message: msg)
        } loginFail: { [weak self] in
            self?.hidenActivityIndicator()
        }
    }
    
    
    @objc func leavBtnClick() {
        handleUpload(isSummarize: false)
    }
    
    func loadRequest() {
        self.showActivityIndicator()
        MONetDataServer.shared().parsePasteboardContent(withContent: linkStr) { [weak self] dict in
            guard let self = self else { return }
            self.hidenActivityIndicator()
            self.dataModel = MOParsePasteboardContentModel.yy_model(withJSON: dict as Any)
            DLog("\(String(describing: dict?.debugDescription))")
            self.textInputView.isHidden = true
            self.setupUI()
            self.updateUIWithRecognitionData()
            self.setupConstraints()
            self.addAction()
        } failure: { [weak self] error in
            self?.handleRequestFailure(error: error)
        } msg: { [weak self] msg in
            self?.handleRequestFailure(message: msg)
        } loginFail: { [weak self] in
            self?.hidenActivityIndicator()
        }
    }
    
    private func handleRequestFailure(error: Error? = nil, message: String? = nil) {
        hidenActivityIndicator()
        let errorMessage = error?.localizedDescription ?? message
        showErrorMessage(errorMessage)
    }
    
    func updateUIWithRecognitionData() {
        if self.dataModel?.status == 2 {
            topView.textLabel.text = self.linkStr
            return
        }
        
        topView.textLabel.text = self.dataModel?.content ?? self.linkStr
        
        if let dataModel = self.dataModel {
            typeView.configView(dataModel: dataModel)
            typeView.didClickData = { [weak self] _ in
                self?.handleTypeViewClick(dataModel: dataModel)
            }
        }
    }
    
    private func handleTypeViewClick(dataModel: MOParsePasteboardContentModel) {
        guard dataModel.cate == 4 || dataModel.cate == 2 else { return }
        
        let model = MOBrowseMediumItemModel()
		model.type = (dataModel.cate == 4) ? MOBrowseMediumItemType.init(rawValue: 1) : MOBrowseMediumItemType.init(rawValue: 0)
        model.url = dataModel.resource_url
        
        let browserVC = MOBrowseMediumVC(dataList: [model], selectedIndex: 0)
        browserVC.modalTransitionStyle = .crossDissolve
        browserVC.modalPresentationStyle = .overFullScreen
        present(browserVC, animated: true)
    }
    func processingVideoData(linkStr:String,complete:(@escaping (_ outputUrl:URL?,_ thumbnailPathUrl:String?)->Void)) {
        
        let path = URL(string: linkStr)
        if let path = path {
            let vdieoModel = self.createVideo(videoURL:path)
            let thumbnailPath = linkStr.replacingOccurrences(of: vdieoModel.fileExtension, with: "jpg")
            
            if let thumbnailPathUrl = URL(string: thumbnailPath) {
                try? vdieoModel.thumbnail.jpegData(compressionQuality: 1.0)?.write(to: thumbnailPathUrl)
            }
            if path.pathExtension.lowercased() == "mov" {
                let newPath = linkStr.replacingOccurrences(of: path.lastPathComponent, with: "\(UUID().uuidString).mp4")
                if let newpathURL = URL(string: newPath) {
                    convertMOVToMP4(inputURL: path, outputURL: newpathURL) { url, error in
                        if error == nil {
                            complete(newpathURL,thumbnailPath)
                        }else {
                            complete(path,thumbnailPath)
                        }
                    }
                } else {
                    complete(path,thumbnailPath)
                }
            }else {
                complete(path,thumbnailPath)
            }
            
        } else {
            complete(nil,nil)
        }
        
    }
    func setupUIwithLocalData(){
		
		self.textInputView.isHidden = true
		
        topView.textLabel.text = self.linkStr
        islocalFile = true
        let path = URL(string: linkStr)
        guard let path else {return}
        let fileExtension = path.pathExtension.lowercased()
        let file_name = path.lastPathComponent

        // 3. 定义常见图片/视频扩展名/音频扩展
        let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "heif", "webp"]
        let videoExtensions: Set<String> = ["mp4", "mov", "avi", "mkv", "flv", "wmv", "mpeg", "3gp", "webm"]
        let audioExtensions: Set<String> = ["mp3", "wav", "flac", "aac", "m4a", "oog", "wma", "amr"]
        
        let model = MOParsePasteboardContentModel()
        model.file_name = file_name
        model.cate = 3
        model.resource_url = path.absoluteString
        model.preview_url = path.absoluteString
        if imageExtensions.contains(fileExtension) {
            model.cate = 2
        }
        if videoExtensions.contains(fileExtension) {
            model.cate = 4
            model.preview_url = videoThumbnailPath
        }
        if audioExtensions.contains(fileExtension) {
            model.cate = 1
			let audioAsset = AVAsset(url: path)
			model.duration = Int(CMTimeGetSeconds(audioAsset.duration) * 1000)
        }
        
        dataModel = model
        typeView.configView(dataModel: model)
        typeView.didClickData = {[weak self] index in
            guard let self,let dataModel else {return}
            if dataModel.cate == 4 || dataModel.cate == 2{
                let  model = MOBrowseMediumItemModel()
                model.type = dataModel.cate == 4 ? MOBrowseMediumItemType.init(rawValue: 1):MOBrowseMediumItemType.init(rawValue: 0)
                model.url =  dataModel.resource_url
                let browserVC = MOBrowseMediumVC.init(dataList: [model], selectedIndex: 0)
                browserVC.modalTransitionStyle = .crossDissolve
                browserVC.modalPresentationStyle = .overFullScreen
                self.present(browserVC, animated: true)
                
            }
        }
        
    }
    
    func convertMOVToMP4(inputURL: URL,outputURL: URL,completion: @escaping(URL?, Error?)->Void) {
            // 检查输入文件是否存在
            guard FileManager.default.fileExists(atPath: inputURL.path) else {
                completion(nil, NSError(domain: "VideoConverter", code: 1001, userInfo: [NSLocalizedDescriptionKey: "输入文件不存在"]))
                return
            }
            
            // 创建 AVAsset 表示输入视频
            let asset = AVURLAsset(url: inputURL)
            
            // 创建导出会话
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
                completion(nil, NSError(domain: "VideoConverter", code: 1002, userInfo: [NSLocalizedDescriptionKey: "无法创建导出会话"]))
                return
            }
            
            // 设置输出参数
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            // 设置视频和音频的元数据处理
            exportSession.metadata = asset.metadata
            
            // 开始导出
            exportSession.exportAsynchronously {
                DispatchQueue.main.async {
                    switch exportSession.status {
                    case .completed:
                        completion(outputURL, nil)
                    case .failed:
                        completion(nil, exportSession.error)
                    case .cancelled:
                        completion(nil, NSError(domain: "VideoConverter", code: 1003, userInfo: [NSLocalizedDescriptionKey: "转换已取消"]))
                    default:
                        completion(nil, NSError(domain: "VideoConverter", code: 1004, userInfo: [NSLocalizedDescriptionKey: "未知错误"]))
                    }
                }
            }
        }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupBeforLoadRequestUI(){
        navBar.gobackDidClick = { [weak self] in
            guard let self = self else { return }
            self.performBackAction()
        }
        
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    private func performBackAction() {
        if let nav = self.navigationController {
            if nav.viewControllers.first === self {
                // 当前是导航栈根且可能为模态呈现，优先关闭模态
                if nav.presentingViewController != nil {
                    nav.dismiss(animated: true)
                } else {
                    nav.popViewController(animated: true)
                }
            } else {
                nav.popViewController(animated: true)
            }
        } else if self.presentingViewController != nil {
            // 无导航控制器，但以模态呈现
            self.dismiss(animated: true)
        } else {
            // 兜底：使用全局过渡的 pop（适用于非模态、主栈场景）
            MOAppDelegate().transition.popViewController(animated: true)
        }
    }
	
	func setupInputStyle(){
		
		textInputView.didClickStartRecognitionBtn = {[weak self] in
			guard let self else {return}
			if textInputView.textView.text.count == 0 {
				self.showMessage(NSLocalizedString("请输入文本或者URL", comment: ""))
				return
			}
			self.linkStr = textInputView.textView.text
			checkLocalFile()
			
		}
		view.addSubview(textInputView)
		textInputView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBar.snp.bottom).offset(10)
		}
	}
	
	func checkLocalFile(){
		
		if !linkStr.hasPrefix("file://") {
			loadRequest()
			return
		}
		
		let videoExtensions: Set<String> = ["mp4", "mov", "avi", "mkv", "flv", "wmv", "mpeg", "3gp", "webm"]
		let path = URL(string: linkStr)
		let fileExtension = path?.pathExtension.lowercased() ?? ""
		if videoExtensions.contains(fileExtension) {
			self.showActivityIndicator()
			processingVideoData(linkStr: linkStr) {[weak self] outputUrl, thumbnailPathUrl in
				guard let self else {return}
				self.hidenActivityIndicator()
				
				linkStr = outputUrl?.absoluteString ?? linkStr
				videoThumbnailPath = thumbnailPathUrl
				setupUI()
				setupConstraints()
				setupUIwithLocalData()
				addAction()
			}
			return
		}
		
		setupUI()
		setupConstraints()
		setupUIwithLocalData()
		addAction()
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBeforLoadRequestUI()

        if needToInput {
            textInputView.isHidden = false
            setupInputStyle()
        } else if formPasteboard {
            loadRequest()
        } else {
            checkLocalFile()
        }
    }
}
