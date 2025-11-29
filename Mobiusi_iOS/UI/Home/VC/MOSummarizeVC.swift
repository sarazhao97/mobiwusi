//
//  MOSummarizeVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import UIKit
import Foundation
// 添加SDWebImage依赖
import SDWebImage
class MOSummarizeVC:MOBaseViewController {
    
    var cate:Int = 0
    var resultId:Int = 0
    var dataModel:MOSummaryDetailModel?
	var previewImageUrl:String?
	var pollingTimer: Timer?
    private static let defaultMindMapURL = "https://app-api.mobiwusi.com/static/app/image/mindmap_default.png"
    private let shareTitle = NSLocalizedString("Mobiwusi神助攻！一键生成的总结和导图，快来看看！", comment: "")
	
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString(NSLocalizedString("资讯分析师", comment: ""), comment: "")
        navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
        return navBar
    }()
	
	lazy var shareBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_mind_share"))
		return btn
	}()
    
    
    lazy var segmentView = {
        let vi = MOSegmentView()
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var summarizeScrollView = {
        let scroll = MOSummarizeScrollView()
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    lazy var topologyMapScrollView = {
        let scroll = MOTopologyMapScrollView()
        return scroll
    }()
	
	lazy var bottomView = {
		let vi = MOSummarizeBottomView()
		vi.backgroundColor = WhiteColor
		return vi
	}()
    
    
    @objc init(cate:Int,resultId:Int,previewImageUrl:String?) {
        self.cate = cate
        self.resultId = resultId
		self.previewImageUrl = previewImageUrl
        super.init(nibName: nil, bundle: nil)
        
    }
	
	@objc init(dataModel:MOSummaryDetailModel,previewImageUrl:String?) {
		self.dataModel = dataModel
		self.previewImageUrl = previewImageUrl
		super.init(nibName: nil, bundle: nil)
		
	}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        summarizeScrollView.linkDidClick = {[weak self] in
            guard let self else {return}
            let url = URL(string: dataModel?.source ?? "")
            if url?.scheme?.lowercased() == "https" || url?.scheme?.lowercased() == "http" {
                let vc = MOWebViewController.createWebViewFromStoryBoard()
                vc.webTitle = dataModel?.source ?? ""
                vc.url = dataModel?.source ?? ""
                MOAppDelegate().transition.push(vc, animated: true)
            }
        }
		
		summarizeScrollView.topologyMapView.didClickRoate = {[weak self] in
			guard let self else {return}
			let vc = MOTopologyMapVC(imageUrl: self.dataModel?.mind_map ?? "")
			MOAppDelegate().transition.push(vc, animated: false)
			if #available(iOS 16.0, *) {
				// iOS 16.0 及以上，什么都不做，交给系统或用 present
			} else {
				// iOS 15.x 及以下，执行强制横屏
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
					UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKeyPath: "orientation")
					UIViewController.attemptRotationToDeviceOrientation()
				}
			}
		}
		summarizeScrollView.topologyMapView.refreshBtn.isHidden = self.cate == 0
		summarizeScrollView.topologyMapView.didClickRefresh = {[weak self] in
			guard let self else {return}
			pollForMindMapUpdate()
		}
		
		summarizeScrollView.headerView.didClickFile =  {[weak self] _ in
			guard let self else {return}
			showFile()
		}
		
		summarizeScrollView.headerView.didPreviewClick =  {[weak self] in
			guard let self else {return}
			if dataModel?.result?.first?.cate == 2 {
				showImageSummarizeData()
				return
			}
			showVideoSummarizeData()
		}
		
        if let dataModel {
            summarizeScrollView.configView(dataModel: dataModel)
        }
        
        view.addSubview(summarizeScrollView)
		if let dataModel {
			bottomView.configView(model: dataModel)
		}
		
		bottomView.didLetfBtnClick = { [weak self] in
			guard let self else {return}
			guard let dataModel else {return}
			let title = NSLocalizedString(shareTitle, comment: "")
			let description =  dataModel.summary ?? ""
			var imageUrl = ""
			if let result = dataModel.result?.first {
				if result.cate == 2 || result.cate == 4 {
					imageUrl = result.preview_url ?? ""
				}
			}
			
			let shareURL = dataModel.share_url ?? ""
			MOSharingManager.shared.share(title: title, description: description, imageUrl: imageUrl, shareURL: shareURL, from: self,shareOption: .shareLink) {[weak self] success in
				guard let self else {return}
				if success {
					summaryOperation(operationType: 3)
				}
			}
			
		}
		
		bottomView.didCenterBtnClick = { [weak self] in
			guard let self else {return}
			summaryOperation(operationType: 1)
		}
		
		bottomView.didRightBtnClick = { [weak self] in
			guard let self else {return}
			guard let dataModel else {return}
			if (dataModel.is_mine) {
				goMessageList()
				return
			}
			summaryOperation(operationType: 2)
		}
		view.addSubview(bottomView)
        
    }
    
    func setupConstraints(){
        
        
        summarizeScrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom).offset(10)
        }
//		self.navBar.rightItemsView.addArrangedSubview(self.shareBtn)
		
		bottomView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(summarizeScrollView.snp.bottom)
			make.bottom.equalToSuperview()
		}
		
    }
	
	func addActions(){
//		shareBtn.addTarget(self, action: #selector(shareBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	
	func goMessageList() {
		if let dataModel {
			let  vc = MOSumarizeMessageListVC(presentationCustomStyle: dataModel.model_id)
			self.present(vc, animated: true)
		}
		
	}


    
    func loadRequest(){
        self.showActivityIndicator()
        MONetDataServer.shared().getSummaryDetail(withCate: self.cate, resultId: self.resultId, success: { [weak self] dict in
            self?.handleSuccessfulResponse(with: dict)
        }, failure: { [weak self] error in
            self?.handleFailedResponse(with: error?.localizedDescription)
        }, msg: { [weak self] msg in
            self?.handleFailedResponse(with: msg)
        }, loginFail: { [weak self] in
            self?.handleFailedResponse(with: nil)
        })
    }

    private func handleSuccessfulResponse(with dict: [AnyHashable: Any]?) {
        self.hidenActivityIndicator()
        if let dataModel = MOSummaryDetailModel.yy_model(withJSON: dict as Any) {
            self.configure(with: dataModel)
			
        }
    }

    private func handleFailedResponse(with errorMessage: String?) {
        self.hidenActivityIndicator()
        if let message = errorMessage {
            self.showErrorMessage(message)
        }
    }
    
    func setupUIBeforLoadRequest() {
        view.addSubview(navBar)
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        navBar.gobackDidClick = { [weak self] in
            guard let self = self else { return }
            // 优先使用当前视图控制器的导航控制器来返回
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                // 如果没有导航控制器，使用全局 transition
                MOAppDelegate().transition.popViewController(animated: true)
            }
        }
    }
	
	
	func showFile() {
		guard let  model = dataModel else {return}
		if model.paste_board_url?.count == 0 {
			return
		}
		let fileModel = model.result?.first as? MOGetSummaryListItemResultModel
		let navVC = MOWebViewController.createWebViewAlertStyle(withTitle: fileModel?.file_name ?? "", url: model.paste_board_url ?? "")
		let webVC = navVC.viewControllers.first
		if let webVC1 = webVC as? MOWebViewController {
			webVC1.closeHandle = {vc in
				vc.dismiss(animated: true)
			}
		}
		
		self.present(navVC, animated: true)
		
	}
	
	func showImageSummarizeData() {
		
		guard let  model = dataModel else {return}
		guard let  result = model.result?.first else {return}
		var dataList:[MOBrowseMediumItemModel] = [];
		let imageModel = MOBrowseMediumItemModel();
		imageModel.type =  MOBrowseMediumItemType.init(rawValue: 0)
		imageModel.url = result.path;
		dataList.append(imageModel)
		let vc = MOBrowseMediumVC(dataList: dataList, selectedIndex: 0);
		vc.modalPresentationStyle = .overFullScreen;
		vc.modalTransitionStyle = .crossDissolve;
		self.present(vc, animated: true)
	}
	
	func showVideoSummarizeData() {
		
		guard let  model = dataModel else {return}
		guard let  result = model.result?.first else {return}
		var dataList:[MOBrowseMediumItemModel] = [];
		let imageModel = MOBrowseMediumItemModel();
		imageModel.type =  MOBrowseMediumItemType.init(rawValue: 1)
		imageModel.url = result.path;
		dataList.append(imageModel)
		let vc = MOBrowseMediumVC(dataList: dataList, selectedIndex: 0);
		vc.modalPresentationStyle = .overFullScreen;
		vc.modalTransitionStyle = .crossDissolve;
		self.present(vc, animated: true)
	}
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIBeforLoadRequest()
        
        if let dataModel = dataModel {
            self.configure(with: dataModel)
        } else {
            loadRequest()
        }
    }
    
    private func configure(with dataModel: MOSummaryDetailModel) {
        self.dataModel = dataModel
        self.setupUI()
        self.setupConstraints()
        self.addActions()
        self.startPollingIfNeeded()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		let toVC = self.transitionCoordinator?.viewController(forKey: UITransitionContextViewControllerKey.to)
		if toVC != nil {
			self.pollingTimer?.invalidate()
		}
	}
	
	@objc func pollForMindMapUpdate() {
        MONetDataServer.shared().getSummaryDetail(withCate: self.cate, resultId: self.resultId) { [weak self] dict in
            guard let self = self else { return }
            let newDataModel = MOSummaryDetailModel.yy_model(withJSON: dict as Any)
            if newDataModel?.mind_map != MOSummarizeVC.defaultMindMapURL {
                self.dataModel = newDataModel
                if let dataModel = self.dataModel {
                    self.summarizeScrollView.configView(dataModel: dataModel)
                }
				self.stopPolling()
            }
        } failure: { [weak self] _ in
            self?.stopPolling()
        } msg: { [weak self] _ in
            self?.stopPolling()
        } loginFail: { [weak self] in
            self?.stopPolling()
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    func startPollingIfNeeded() {
        if dataModel?.mind_map == MOSummarizeVC.defaultMindMapURL {
            stopPolling()
            pollingTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(pollForMindMapUpdate), userInfo: nil, repeats: true)
        }
    }
	
	
	func summaryOperation(operationType:Int){
		
		guard let model = dataModel else {return}
		
		let request = MOSummaryOperationRequest()
		request.operation_type = operationType
		if operationType == 1 {
			request.operation_status = model.is_like ? 0:1
		}
		if operationType == 2 {
			request.operation_status = model.is_unlike ? 0:1
		}
		if operationType == 3 {
			request.operation_status = 1
		}
		
		request.model_id = model.model_id
		if operationType == 1 || operationType == 2 {
			self.showActivityIndicator()
		}
		
		request.startRequest {[weak  self] error, data in
			guard let self else {return}
			
			if operationType != 3 {
				self.hidenActivityIndicator()
				if let error {
					self.showErrorMessage(error)
					return
				}
			}
			
			if operationType == 1,let count = data as? Int {
				model.like_num = count
				model.is_like = !model.is_like
			}
			if operationType == 2,let count = data as? Int {
				model.unlike_num = count
				model.is_unlike = !model.is_unlike
			}
			if operationType == 3 ,let count = data as? Int{
				model.share_num = count
			}
			bottomView.configView(model: model)
			
			
			
		}
	}
}



