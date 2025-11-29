//
//  MOCheckedPasteboardLinkVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
import SwiftUI
@objcMembers
	class MOCheckedPasteboardLinkVC: MOBaseViewController {
    
		var didClickRecognitionBtn:(()->Void)?
		nonisolated(unsafe) var linkStr:String
		nonisolated(unsafe) var dataModel:MOParsePasteboardContentModel?
		nonisolated(unsafe) var hasNavigatedToSummarize: Bool = false
		lazy var bgContentView = {
        let vi = MOView()
        vi.backgroundColor = ClearColor
        return vi
    }()
    
    lazy var centerContentView = {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.all, radius: 20)
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    lazy var topImageview = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_check_link")
        return imageView
    }()
    
    lazy var  tipLabel = {
        let label = UILabel(text: NSLocalizedString("检测到您复制了视频或文章链接，是否要打开", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(14))
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var analysisBtn = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("开始解析", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCHeavyFont(17))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        return btn
    }()
    
    lazy var closeBtn = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_ProfitReminder_close_white"))
        btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
        return btn
    }()
    
    func setupUI(){
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        view.addSubview(bgContentView)
        
        bgContentView.addSubview(centerContentView)
        bgContentView.addSubview(topImageview)
        centerContentView.addSubview(tipLabel)
        centerContentView.addSubview(analysisBtn)
        view.addSubview(closeBtn)
    }
    
    func setupConstraints(){
        
        bgContentView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        topImageview.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        centerContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(29)
            make.right.equalToSuperview().offset(-29)
            make.top.equalTo(topImageview.snp.top).offset(80)
            make.bottom.equalToSuperview()
        }
        
        
        
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topImageview.snp.bottom)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        analysisBtn.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-23)
            make.height.equalTo(55)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.top.equalTo(centerContentView.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
        }
    }
    
    func addActions(){
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: UIControl.Event.touchUpInside)
        analysisBtn.addTarget(self, action: #selector(analysisBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func closeBtnClick(){
        
        self.dismiss(animated: true)
    }
    
    @objc func analysisBtnClick(){
        
		loadRequest()
        
        
    }
	
	private func findAndPopToVC<T: UIViewController>(type: T.Type, notificationName: NSNotification.Name?, createVC: @autoclosure () -> T) {
		let transition = MOAppDelegate().transition!
		if let existingVC = transition.navigationChildViewControllers().first(where: { $0 is T }) {
			if let notificationName = notificationName {
				NotificationCenter.default.post(name: notificationName, object: nil)
			}
			existingVC.hidesBottomBarWhenPushed = true
			transition.pop(to: existingVC, animated: true)
		} else {
			let newVC = createVC()
			let currentCount = transition.navigationVCViewControllersCount()
			newVC.hidesBottomBarWhenPushed = true
			transition.insertVC(newVC, index: currentCount - 1)
			if let notificationName = notificationName {
				NotificationCenter.default.post(name: notificationName, object: nil)
			}
			transition.pop(to: newVC, animated: true)
		}
	}
	
	func loadRequest() {
		self.showActivityIndicator()
		
		let taskGroup = DispatchGroup()
		let queue = DispatchQueue(label: "taskList",attributes: DispatchQueue.Attributes.concurrent)
		nonisolated(unsafe) var  errorMsg:String?
		nonisolated(unsafe) var isFail = false
		queue.async {[weak self] in
			guard let self else {return}
			taskGroup.enter()
			queue.async(group: taskGroup, execute: {
				MONetDataServer.shared().parsePasteboardContent(withContent: self.linkStr) { [weak self] dict in
					guard let self = self else { return }
					self.dataModel = MOParsePasteboardContentModel.yy_model(withJSON: dict as Any)
					// 解析成功后立即跳转到资讯分析师页面
					DispatchQueue.main.async {
						self.hidenActivityIndicator()
						self.hasNavigatedToSummarize = true
						// 先关闭当前弹层，再在完成回调中进行页面跳转，避免并发导航导致交互异常
						self.dismiss(animated: true) {
						// 跳转到资讯分析师页面（使用 UIKit 导航栈，而非 SwiftUI NavigationLink）
						MOAppDelegate().transition.push(MOSummarizeSampleVC(), animated: true)
						}
					}
					taskGroup.leave()
				} failure: { error in
					errorMsg = error?.localizedDescription
					isFail = true
					taskGroup.leave()
				} msg: { msg in
					errorMsg = msg
					isFail = true
					taskGroup.leave()
				} loginFail: { [weak self] in
					guard let self = self else { return }
					isFail = true
					taskGroup.leave()
				}
				
			})
			
			taskGroup.wait()
			if let dataModel {
				
				if self.dataModel?.cate == 3, let extract_content = dataModel.extract_content, !extract_content.isEmpty {
					let fileName = String(format: "%@.txt", self.dataModel?.title ?? "")
					let fileData = self.dataModel?.extract_content?.data(using: .utf8, allowLossyConversion: true)
					
					let user_data = MOUploadFileDataModel()
					user_data.file_name = fileName
					user_data.size = fileData?.count ?? 0
					user_data.format = "txt"
					
					taskGroup.enter()
					MONetDataServer.shared().uploadFile(withFileName: fileName, fileData: fileData, mimeType: "text/plain") { dict in
						
						let fileServerRelativeUrl = dict?["relative_url"] as? String
						user_data.url = fileServerRelativeUrl
						taskGroup.leave()
						
					} failure: { error in
						errorMsg = error?.localizedDescription
						isFail = true
						taskGroup.leave()
					} loginFail: {
						isFail = true
						taskGroup.leave()
					}
					
					taskGroup.wait()
					let userDataStr = NSArray(object: user_data).yy_modelToJSONString()
					taskGroup.enter()
					MONetDataServer.shared().unlimitedUploadData(withCateId: self.dataModel?.cate ?? 0, idea: "", location: "", user_data: userDataStr, content_id: self.dataModel?.model_id ?? 0, is_summarize: true) {
						taskGroup.leave()
					} failure: {error in
						errorMsg = error?.localizedDescription
						isFail = true
						taskGroup.leave()
					} msg: { msg in
						errorMsg = msg
						isFail = true
						taskGroup.leave()
					} loginFail: {
						isFail = true
						taskGroup.leave()
					}
					
					
				} else {
					taskGroup.enter()
					MONetDataServer.shared().writePasteboardContentWithcontentId(dataModel.model_id, isSummarize: true) {
						taskGroup.leave()
					} failure: { error in
						errorMsg = error?.localizedDescription
						isFail = true
						taskGroup.leave()
					} msg: { msg in
						errorMsg = msg
						isFail = true
						taskGroup.leave()
						
					} loginFail: {
						isFail = true
						taskGroup.leave()
					}
				}
			}
			
			taskGroup.notify(queue: DispatchQueue.main) {
				
				let tmpIsFail = isFail
				let tmpErrorMsg = errorMsg
				DispatchQueue.main.async {
					// 已在解析成功时提前跳转，避免重复处理
					if self.hasNavigatedToSummarize {
						return
					}
					self.hidenActivityIndicator()
					if tmpIsFail {
						self.showErrorMessage(tmpErrorMsg)
						self.dismiss(animated: true)
						return
					}
					self.dismiss(animated: true) {
						self.findAndPopToVC(type: MOSummarizeSampleVC.self, notificationName: .SummarizeSampleNeedRefresh, createVC: MOSummarizeSampleVC())
						
					}
				}
				
				
			}
			
			
		}
		
		
		
		
	}
    
    class func createAlertStyle(linkStr: String)->MOCheckedPasteboardLinkVC{
        let vc = MOCheckedPasteboardLinkVC(linkStr: linkStr)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        return vc
    }
	
	init(linkStr: String) {
		self.linkStr = linkStr
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
    }
}
