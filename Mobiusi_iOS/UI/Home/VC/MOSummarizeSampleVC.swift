//
//  MOSummarizeSampleVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/12.
//

import UIKit
import SwiftUI

@objcMembers
class MOSummarizeSampleVC: MOBaseViewController {
	
	nonisolated(unsafe) var page = 1;
	nonisolated(unsafe) var limit = 20;
	var currentPlayingIndex:Int = 0
	nonisolated(unsafe) var dataList:[MOUserTaskDataModel] = []
	var summarySquareVC = MOSummarySquareVC()
	var mySummaryVC = MOMySummaryVC()
	lazy var bgView = {
		let vi = MOView()
		vi.backgroundColor = UIColor.color(fromHex: "ECEEF4")
		return vi
	}()
	lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString(NSLocalizedString("资讯分析师", comment: ""), comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b.png"))
		return navBar
	}()
	
	private lazy var navBarContentView = {
		let vi = MOView()
		vi.clipsToBounds = true
		return vi
	}()
	
	lazy var historyBtn = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_sunmmarize_history"))
		return btn
	}()
	
	
	lazy var leftContentView = {
		let vi = MOView()
		vi.backgroundColor = Color34C759
		return vi
	}()
	
	lazy var rightContentView = {
		let vi = MOView()
		vi.backgroundColor = ColorFF4A4A
		return vi
	}()
	


	
	lazy var bottomView = {
		let vi  = MOSummarizeSampleBottomView()
		return vi
	}()
	
	func setupUI(){
		
		bottomView.isHidden = false

		
		bottomView.didClickUploadBtn = {[weak self] in
			guard let self else {return}
			let allowedTypes = ["public.item"]
			let documentPicker = UIDocumentPickerViewController.init(documentTypes: allowedTypes, in: UIDocumentPickerMode.import)
			documentPicker.allowsMultipleSelection = false
			documentPicker.delegate = self
			documentPicker.modalPresentationStyle = .fullScreen
			documentPicker.modalTransitionStyle = .crossDissolve
			self.present(documentPicker, animated: true)
		}
		
		bottomView.didClickTextBtn = { [weak self] in
			guard let self else { return }
			// let vc =  MOLinkRecognitionVC(needToInput: true)
			// MOAppDelegate().transition.push(vc, animated: true)
			let baseView = InformationAnalysis()
			let rootView = baseView
				.toolbarColorScheme(.dark)
			let vc = UIHostingController(rootView: rootView)
			vc.hidesBottomBarWhenPushed = true
			// 优先在当前模态的导航栈中进行 push，避免被上层 modal 覆盖
			if let nav = self.navigationController {
				nav.pushViewController(vc, animated: true)
			} else {
				// 兜底：若当前没有导航栈，则以全屏方式 present 一个导航容器
				let navController = UINavigationController(rootViewController: vc)
				navController.modalPresentationStyle = .fullScreen
				navController.modalTransitionStyle = .coverVertical
				self.present(navController, animated: true)
			}
		}
		
	}
	
	func setupConstraints(){
		
		navBarContentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		bgView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
			make.height.equalTo(244)
		}
		
		
		leftContentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBarContentView.snp.bottom)
			make.bottom.equalToSuperview()
			
		}
		summarySquareVC.view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		mySummaryVC.view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		rightContentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBarContentView.snp.bottom)
			make.bottom.equalToSuperview()
			
		}
		
		
		bottomView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(55 + (Bottom_SafeHeight > 0 ? Bottom_SafeHeight : 20))
		}
		
		
	}

	
	func uploadBtnClick(){
		
		let allowedTypes = ["public.item"]
		let documentPicker = UIDocumentPickerViewController.init(documentTypes: allowedTypes, in: UIDocumentPickerMode.import)
		documentPicker.allowsMultipleSelection = false
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = .overFullScreen
		documentPicker.modalTransitionStyle = .crossDissolve
		self.present(documentPicker, animated: true)
		
	}
	
	func textBtnClick(){
		let vc =  MOLinkRecognitionVC(needToInput: true)
		MOAppDelegate().transition.push(vc, animated: true)
	}
	
	func historyBtnClick(){
		let alldataVC = MOMyAllDataVC.init(cate: 0, userTaskId: 0,user_paste_board: true)
		MOAppDelegate().transition.push(alldataVC, animated: true)
	}
	
	
	
	func initializationUI(){
		
		// 无条件设置返回按钮的回调，统一使用全局 transition 的智能关闭：
		// 若当前在主导航栈中，则执行 pop；若为模态呈现，则执行 dismiss
		navBar.gobackDidClick = { [weak self] in
			guard let self = self else { return }
			MOAppDelegate().transition.dismiss(self, animated: true, completion: nil)
		}
		view.addSubview(bgView)
		
		navBarContentView.addSubview(navBar)
		view.addSubview(navBarContentView)
		
		
		
		
		
		
		view.addSubview(leftContentView)
		summarySquareVC.view.setNeedsDisplay()
		// 设置父视图控制器引用，方便子视图控制器访问导航控制器
		summarySquareVC.summarizeSampleVC = self
		summarySquareVC.manuallyRefresh()
		summarySquareVC.WillEndDragging = {[weak self] velocity in
			guard let self else {return}
			bottomViewShowOrHidden(velocity: velocity)
			
		}
		leftContentView.addSubview(summarySquareVC.view)
		
		rightContentView.isHidden = true
		view.addSubview(rightContentView)
		mySummaryVC.view.setNeedsDisplay()
		mySummaryVC.WillEndDragging = {[weak self] velocity in
			guard let self else {return}
			bottomViewShowOrHidden(velocity: velocity)
			
		}
		rightContentView.addSubview(mySummaryVC.view)
		
		view.addSubview(bottomView)
		
	}
	
	func showFile(model:MOUserTaskDataModel) {
		
		let fileModel = model.result.firstObject as? MOUserTaskDataResultModel
		let navVC = MOWebViewController.createWebViewAlertStyle(withTitle: fileModel?.file_name ?? "", url: model.paste_board_url ?? "")
		let webVC = navVC.viewControllers.first
		if let webVC1 = webVC as? MOWebViewController {
			webVC1.closeHandle = {vc in
				vc.dismiss(animated: true)
			}
		}
		
		self.present(navVC, animated: true)
		
	}
	// 公共方法：设置返回按钮的回调
	func setBackButtonAction(_ action: @escaping () -> Void) {
		navBar.gobackDidClick = action
	}
	
	func goSummarizeVC(model:MOUserTaskDataModel) {
		// 当总结状态为成功时，跳转到 SwiftUI 全屏视图
		if model.summarize_status == 2 {
			// 构造 IndexItem，最小化满足 FullScreenViewController 的数据需求
			let item = IndexItem(
				post_id: String(model.model_id),
				id: model.model_id,
				create_time: model.upload_time ?? "",
				task_title: model.task_title,
				location: model.location,
				cate: model.cate,
				parent_post_id: "",
				user_task_id: nil,
				task_id: nil,
				description: nil,
				idea: model.idea,
				source: 5, // 资讯分析类型，以展示 AnalysisFullScreenView
				is_authentication: nil,
				meta_data: nil,
				fraction: 0,
				is_feature: nil,
				ai_tool: nil,
				annotation: nil,
				transaction: nil,
				continuity: nil,
				knowledge_graph: nil
			)
			
			// 使用 UIHostingController 包装 SwiftUI 视图
			let hostingVC = UIHostingController(rootView: FullScreenViewController(data: item))
			hostingVC.modalPresentationStyle = .fullScreen
			
			// 若存在导航控制器，优先使用 push；否则使用全局 transition
			if let navController = self.navigationController {
				navController.pushViewController(hostingVC, animated: true)
			} else {
				MOAppDelegate().transition.push(hostingVC, animated: true)
			}
		}
	}
	
	func showImageSummarizeData(model:MOUserTaskDataResultModel) {
		var dataList:[MOBrowseMediumItemModel] = [];
		let imageModel = MOBrowseMediumItemModel();
		imageModel.type =  MOBrowseMediumItemType.init(rawValue: 0)
		imageModel.url = model.path;
		dataList.append(imageModel)
		let vc = MOBrowseMediumVC(dataList: dataList, selectedIndex: 0);
		vc.modalPresentationStyle = .overFullScreen;
		vc.modalTransitionStyle = .crossDissolve;
		self.present(vc, animated: true)
	}
	
	func showVideoSummarizeData(model:MOUserTaskDataResultModel) {
		var dataList:[MOBrowseMediumItemModel] = [];
		let imageModel = MOBrowseMediumItemModel();
		imageModel.type =  MOBrowseMediumItemType.init(rawValue: 1)
		imageModel.url = model.path;
		dataList.append(imageModel)
		let vc = MOBrowseMediumVC(dataList: dataList, selectedIndex: 0);
		vc.modalPresentationStyle = .overFullScreen;
		vc.modalTransitionStyle = .crossDissolve;
		self.present(vc, animated: true)
	}
	
	func goMessageList(mode:MOUserTaskDataModel) {
		let resultModel = mode.result.firstObject as? MOUserTaskDataResultModel
		let vc = MOMessageListVC.init(presentationCustomStyleWithDataId: mode.model_id,dataCate: resultModel?.cate ?? 0, userTaskResultId: resultModel?.model_id ?? 0)
		self.present(vc, animated: true)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	
	func bottomViewShowOrHidden(velocity:CGPoint) {
		
		if velocity.y > 0 {
			UIView.animate(withDuration: 0.5) {
				self.bottomView.snp.remakeConstraints { make in
					make.left.equalToSuperview()
					make.right.equalToSuperview()
					make.top.equalTo(self.view.snp.bottom)
				}
				self.view.layoutIfNeeded()
			}
			
		}
		if velocity.y < 0 {
			UIView.animate(withDuration: 0.5) {
				
				self.bottomView.snp.remakeConstraints { make in
					make.left.equalToSuperview()
					make.right.equalToSuperview()
					make.bottom.equalToSuperview()
				}
				self.view.layoutIfNeeded()
			}
			
		}
	}
	
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializationUI()
        setupUI()
        setupConstraints()
    }
}

extension MOSummarizeSampleVC:UIScrollViewDelegate {
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
//		let target = targetContentOffset.pointee
		if velocity.y > 0 {

				targetContentOffset.pointee = CGPoint(x: 0, y: 0)
			}
		
		if velocity.y < 0 {
			targetContentOffset.pointee = CGPoint(x: 0, y: 0)
		}
		
	}
}

extension MOSummarizeSampleVC:UIDocumentPickerDelegate {
	
	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
		DLog("\(url)")
		
		let vc =  MOLinkRecognitionVC(linkStr: url.absoluteString, fromPasteboard: false)
		let performNavigation = {
			MOAppDelegate().transition.present(vc, animated: true, completion: nil)
		}
		
		if controller.presentingViewController != nil {
			controller.dismiss(animated: true) {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					performNavigation()
				}
			}
		} else {
			DispatchQueue.main.async {
				performNavigation()
			}
		}
	}
	
	public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		
		controller.dismiss(animated: true)
	}
}
