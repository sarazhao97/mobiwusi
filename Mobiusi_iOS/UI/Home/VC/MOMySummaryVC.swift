//
//  MOMySummaryVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/8.
//

import UIKit
import SwiftUI

class MOMySummaryVC: MOBaseViewController {

	
	var WillEndDragging:((_ velocity: CGPoint)->Void)?
	nonisolated(unsafe) var dataList:[MOGetSummaryListItemModel] = []
	var pageIndex = 1;
	var pageSize = 20;
	var currentPlayingIndex:Int = -1
	var showHeader:Bool = false
	@objc var tableView = {
		let table = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableView.Style.grouped)
		table.showsVerticalScrollIndicator = false
		table.separatorColor = ColorF2F2F2
//        table.separatorInset = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
		table.estimatedRowHeight = 0;
		table.separatorStyle = .none
		table.estimatedSectionHeaderHeight = 0
		table.estimatedSectionFooterHeight = 0
		table.backgroundColor = ClearColor
		table.sectionIndexColor = ColorAFAFAF
		table.sectionIndexBackgroundColor = ClearColor
		table.sectionIndexTrackingBackgroundColor = ClearColor
		table.alwaysBounceVertical = true
		table.bounces = true
		table.delaysContentTouches = false
		table.isDirectionalLockEnabled = true
		if #available(iOS 17.4, *) {
			table.bouncesVertically = true
			table.transfersVerticalScrollingToParent = false
		}
		if #available(iOS 15.0, *) {
			table.sectionHeaderTopPadding = 0
		}
		table.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never;
		table.clipsToBounds = true
		return table
	}()
	
	lazy var headerView = {
		let vi = MOPersonHeaderView()
		return vi
	}()
	
	func setupUI(){
		
		tableView.register(MOSummarizeAudioInProcessCell.self, forCellReuseIdentifier: "MOSummarizeAudioInProcessCell")
		tableView.register(MOSummarizeAudioFinishCell.self, forCellReuseIdentifier: "MOSummarizeAudioFinishCell")
		
		tableView.register(MOSummarizeTextInProcessCell.self, forCellReuseIdentifier: "MOSummarizeTextInProcessCell")
		tableView.register(MOSummarizeTextProcesFinishsCell.self, forCellReuseIdentifier: "MOSummarizeTextProcesFinishsCell")
		
		tableView.register(MOSummarizeImageVideoInProcessCell.self, forCellReuseIdentifier: "MOSummarizeImageVideoInProcessCell")
		tableView.register(MOSummarizeImageVideoFinishCell.self, forCellReuseIdentifier: "MOSummarizeImageVideoFinishCell")
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)
		
		if showHeader {
			headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 112)
			tableView.tableHeaderView = headerView
			tableView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 112)
		}
		
		tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
			guard let self else {return}
			pageIndex = 1
			loadRequest()
			
		})
		
		tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: {[weak self] in
			guard let self else {return}
			pageIndex =  pageIndex + 1
			loadRequest()
		})
		self.tableView.mj_footer.isAutomaticallyHidden = true
	}
	
	func setupConstraints(){
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	
	func showFile(model:MOGetSummaryListItemModel) {
		
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
	
	func showImageSummarizeData(model:MOGetSummaryListItemResultModel) {
		var dataList:[MOBrowseMediumItemModel] = [];
		let imageModel = MOBrowseMediumItemModel();
		imageModel.type =  MOBrowseMediumItemType.init(rawValue: 0)
		imageModel.url = model.path;
		dataList.append(imageModel)
		let vc = MOBrowseMediumVC(dataList: dataList, selectedIndex: 0);
		vc.didLongPressImage = {imageUrl in
			MOSharingManager.shared.share(title: "", description: "", imageUrl: model.path ?? "", shareURL: "",from: vc, shareOption:.shareImage)
		}
		vc.modalPresentationStyle = .overFullScreen;
		vc.modalTransitionStyle = .crossDissolve;
		self.present(vc, animated: true)
	}
	
	func showVideoSummarizeData(model:MOGetSummaryListItemResultModel) {
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
	
	func manuallyRefresh(){
		self.tableView.mj_header.beginRefreshing()
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
			self.tableView.mj_header.endRefreshing()
		})
	}
	
	func loadRequest(){
		
		let request = MOGetSummaryListRequest()
		request.page = pageIndex
		request.limit = pageSize
		// request.is_square = false
		request.startRequest {[weak self] error, data in
			guard let self else {return}
			if let error {
				self.showErrorMessage(error)
				return
			}
			let listModelReal:[MOGetSummaryListItemModel] = data as? [MOGetSummaryListItemModel] ?? []
			if pageIndex == 1 {
				self.dataList.removeAll()
				self.currentPlayingIndex = -1;
				self.tableView.fd_keyedHeightCache.invalidateAllHeightCache()
				self.tableView.fd_indexPathHeightCache.invalidateAllHeightCache()
				self.tableView.mj_header.endRefreshing()
				self.tableView.mj_footer.endRefreshingWithNoMoreData()
			}
			
			if pageIndex > 1 {
				if listModelReal.count < pageSize {
					self.tableView.mj_footer.endRefreshingWithNoMoreData()
				}
				
			}
			self.dataList.append(contentsOf: listModelReal)
			
			if showHeader,let firstModel =  self.dataList.first {
				headerView.configView(dataModel: firstModel)
			}
			self.tableView.reloadData()
			
			
		}
	}
	
	func summaryOperation(model:MOGetSummaryListItemModel,operationType:Int){
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
			self.hidenActivityIndicator()
			
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
			tableView.reloadData()
			
		}
	}
	
	func setSummaryOpenStatus(model:MOGetSummaryListItemModel) {
		let request = MOSetSummaryOpenStatusRequest()
		request.model_id = model.model_id
		request.is_open = !model.is_open
		self.showActivityIndicator()
		request.startRequest {[weak  self] errorMsg, data in
			guard let self else {return}
			self.hidenActivityIndicator()
			if let errorMsg {
				self.showErrorMessage(errorMsg)
				return
			}
			model.is_open = !model.is_open
			self.tableView.reloadData()
			
		}
	}
	
	func goSummarizeVC(model:MOGetSummaryListItemModel) {
		if model.summarize_status == 2 {
			// 构造 IndexItem 并跳转到 SwiftUI 全屏视图
			let item = IndexItem(
				post_id: String(model.model_id),
				id: model.model_id,
				create_time: model.update_time ?? model.create_time ?? "",
				task_title: model.title,
				location: nil,
				cate: model.cate,
				parent_post_id: "",
				user_task_id: nil,
				task_id: nil,
				description: nil,
				idea: nil,
				source: 5,
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
			let hostingVC = UIHostingController(rootView: FullScreenViewController(data: item))
			hostingVC.modalPresentationStyle = .fullScreen
			MOAppDelegate().transition.push(hostingVC, animated: true)
		}
	}
	
	func goMessageList(model:MOGetSummaryListItemModel) {
		let  vc = MOSumarizeMessageListVC(presentationCustomStyle: model.model_id)
		self.present(vc, animated: true)
	}
	
	
	init(showHeader:Bool = false) {
		self.showHeader = showHeader
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		DLog("销毁")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		setupConstraints()
		
    }

}


extension MOMySummaryVC {
	
	
	func setInProcessCellCallBack(cell:MOBaseSummarizeInProcessCell,model:MOGetSummaryListItemModel) {
		// 捕获model的副本，避免闭包中直接引用model
		let modelId = model.model_id
		cell.didMsgBtnClick = { [weak self] in
			guard let self else {return}
			// 在dataList中查找对应的model，避免直接使用外部的model引用
			if let index = self.dataList.firstIndex(where: { $0.model_id == modelId }) {
				// 如果需要执行操作，使用dataList中的model
			}
		}
	}
	
	func setFinishCellCallBack(cell:MOBaseSummarizeProcesFinishsCell,model:MOGetSummaryListItemModel) {
		// 捕获model的副本，避免闭包中直接引用model
		let modelId = model.model_id
		let title = NSLocalizedString("Mobiwusi总结", comment: "")
		let description = model.summary ?? ""
		var imageUrl = ""
		if model.cate == 2 || model.cate == 4, let result = model.result?.first {
			imageUrl = result.preview_url ?? ""
		}
		let shareURL = model.share_url ?? ""
		
		cell.shareBtnDidClick = { [weak self] in
			guard let self else {return}
			MOSharingManager.shared.share(title: title, description: description, imageUrl: imageUrl, shareURL: shareURL, from: self, shareOption: .shareLink) {[weak self] success in
				guard let self else {return}
				if success {
					// 在dataList中查找对应的model，避免直接使用外部的model引用
					if let index = self.dataList.firstIndex(where: { $0.model_id == modelId }) {
						self.summaryOperation(model: self.dataList[index], operationType: 3)
					}
				}
			}
		}
		
		cell.didMsgBtnClick = { [weak self] in
			guard let self else {return}
			// 捕获model的副本，避免闭包中直接引用model
			let modelId = model.model_id
			// 在dataList中查找对应的model，避免直接使用外部的model引用
			if let index = self.dataList.firstIndex(where: { $0.model_id == modelId }) {
				self.goMessageList(model: self.dataList[index])
			}
		}
		
		
		cell.likeBtnDidClick = { [weak self] in
			guard let self else {return}
			summaryOperation(model: model, operationType: 1)
		}
		cell.briefIntroductionView.didViewDetailBtnClick = {[weak self] in
			guard let self else {return}
			goSummarizeVC(model: model)
		}
		
		cell.didChangeOpenState = { [weak self] in
			guard let self else {return}
			setSummaryOpenStatus(model: model)
		}
		
		
	}
	
	func getAudioCellHeight(model: MOGetSummaryListItemModel, cacheByKey: String) -> CGFloat {

		if model.summarize_status == 1 || model.summarize_status == 3 {
			let height = tableView.fd_heightForCell(
				withIdentifier: "MOSummarizeAudioInProcessCell",
				cacheByKey: cacheByKey as NSCopying
			) { cell in
				if let cell1 = cell as? MOSummarizeAudioInProcessCell {
					cell1.configAudioCell(dataModel: model)
				}
				
			}
			return height
		}
		
		let height = tableView.fd_heightForCell(withIdentifier: "MOSummarizeAudioFinishCell", cacheByKey: cacheByKey as NSCopying) { cell in
			if let cell1 = cell as? MOSummarizeAudioFinishCell {
				cell1.configAudioCell(dataModel: model)
			}
		}
		
		return height
	}
	
	
	func getTextCellHeight(model: MOGetSummaryListItemModel, cacheByKey: String) -> CGFloat {

		if model.summarize_status == 1 || model.summarize_status == 3 {
			let height = tableView.fd_heightForCell(
				withIdentifier: "MOSummarizeTextInProcessCell",
				cacheByKey: cacheByKey as NSCopying
			) { cell in
				if let cell1 = cell as? MOSummarizeTextInProcessCell {
					cell1.configFileCell(dataModel: model)
				}
				
			}
			return height
		}
		
		let height = tableView.fd_heightForCell(withIdentifier: "MOSummarizeTextProcesFinishsCell", cacheByKey: cacheByKey as NSCopying) { cell in
			if let cell1 = cell as? MOSummarizeTextProcesFinishsCell {
				cell1.configFileCell(dataModel: model)
			}
		}
		
		return height
	}
	
	func getPicTureCellHeight(model: MOGetSummaryListItemModel, cacheByKey: String) -> CGFloat {

		if model.summarize_status == 1 || model.summarize_status == 3 {
			let height = tableView.fd_heightForCell(
				withIdentifier: "MOSummarizeImageVideoInProcessCell",
				cacheByKey: cacheByKey as NSCopying
			) { cell in
				if let cell1 = cell as? MOSummarizeImageVideoInProcessCell {
					cell1.configImageCell(dataModel: model)
				}
				
			}
			return height
		}
		
		let height = tableView.fd_heightForCell(withIdentifier: "MOSummarizeImageVideoFinishCell", cacheByKey: cacheByKey as NSCopying) { cell in
			if let cell1 = cell as? MOSummarizeImageVideoFinishCell {
				cell1.configImageCell(dataModel: model)
			}
		}
		
		return height
	}
	
	
	func getVideoCellHeight(model: MOGetSummaryListItemModel, cacheByKey: String) -> CGFloat {

		if model.summarize_status == 1 || model.summarize_status == 3 {
			let height = tableView.fd_heightForCell(
				withIdentifier: "MOSummarizeImageVideoInProcessCell",
				cacheByKey: cacheByKey as NSCopying
			) { cell in
				if let cell1 = cell as? MOSummarizeImageVideoInProcessCell {
					cell1.configVideoCell(dataModel: model)
				}
				
			}
			return height
		}
		
		let height = tableView.fd_heightForCell(withIdentifier: "MOSummarizeImageVideoFinishCell", cacheByKey: cacheByKey as NSCopying) { cell in
			if let cell1 = cell as? MOSummarizeImageVideoFinishCell {
				cell1.configVideoCell(dataModel: model)
			}
		}
		
		return height
	}
	
	
	func getAudioCell(index:IndexPath) -> UITableViewCell {
		let model = dataList[index.row]
			
		if model.summarize_status == 1 || model.summarize_status == 3 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "MOSummarizeAudioInProcessCell")
			guard let cell else {
				
				return MOSummarizeAudioInProcessCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeAudioInProcessCell")
			}
			if let cell1 = cell as? MOSummarizeAudioInProcessCell {
				cell1.scheduleVerticalTopView.isHidden = index.row == 0
				cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1
				cell1.delegate = self
				
				cell1.configAudioCell(dataModel: model)
				
				let isPlaying = currentPlayingIndex == index.row
				cell1.updatePlayingState(isPlaying: isPlaying)
			}
			
			
			return cell
		}
		
		
		
		
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "MOSummarizeAudioFinishCell"
		)
		guard let cell else {
			
			return MOSummarizeAudioFinishCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeAudioFinishCell")
		}
		if let cell1 = cell as? MOSummarizeAudioFinishCell {
			cell1.scheduleVerticalTopView.isHidden = index.row == 0
			cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1
			cell1.delegate = self
			
			cell1.configAudioCellIsMIne(dataModel: model)
			
			let isPlaying = currentPlayingIndex == index.row
			cell1.updatePlayingState(isPlaying: isPlaying)
			
		}
		
		
		return cell
	}
	
	func getTextCell(index:IndexPath) -> UITableViewCell {
		let model = dataList[index.row]
			
		if model.summarize_status == 1 || model.summarize_status == 3 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "MOSummarizeTextInProcessCell")
			guard let cell else {
				
				return MOSummarizeTextInProcessCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeTextInProcessCell")
			}
			if let cell1 = cell as? MOSummarizeTextInProcessCell {
				cell1.scheduleVerticalTopView.isHidden = index.row == 0;
				cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1;
				cell1.configFileCell(dataModel: model)
				// 捕获必要的信息，避免闭包中直接引用model
				let modelId = model.model_id
				cell1.didClickFile = {[weak self] index in
					guard let self else {return}
					// 在dataList中查找对应的model，避免直接使用外部的model引用
					if let index = self.dataList.firstIndex(where: { $0.model_id == modelId }) {
						self.showFile(model: self.dataList[index])
					}
				}
				self.setInProcessCellCallBack(cell: cell1, model: model)
			}
			
			
			return cell
		}
		
		
		
		
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "MOSummarizeTextProcesFinishsCell"
		)
		guard let cell else {
			
			return MOSummarizeTextProcesFinishsCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeTextProcesFinishsCell")
		}
		if let cell1 = cell as? MOSummarizeTextProcesFinishsCell {
			cell1.scheduleVerticalTopView.isHidden = index.row == 0;
			cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1;
			cell1.configFileCellIsMine(dataModel: model)
			
			// 捕获必要的信息，避免闭包中直接引用model
			let modelId = model.model_id
			cell1.didClickFile = {[weak self] index in
				guard let self else {return}
				// 在dataList中查找对应的model，避免直接使用外部的model引用
				if let index = self.dataList.firstIndex(where: { $0.model_id == modelId }) {
					self.showFile(model: self.dataList[index])
				}
			}
			self.setFinishCellCallBack(cell: cell1, model: model)
			
		}
		
		
		return cell
	}
	
	func getPictureCell(index:IndexPath) -> UITableViewCell {
		let model = dataList[index.row]
			
		if model.summarize_status == 1 || model.summarize_status == 3 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "MOSummarizeImageVideoInProcessCell")
			guard let cell else {
				
				return MOSummarizeImageVideoInProcessCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeImageVideoInProcessCell")
			}
			if let cell1 = cell as? MOSummarizeImageVideoInProcessCell {
				cell1.scheduleVerticalTopView.isHidden = index.row == 0;
				cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1;
				cell1.configImageCell(dataModel: model)
				// 捕获必要的信息，避免闭包中直接引用model
				let resultModel = model.result?.first as? MOGetSummaryListItemResultModel
				cell1.didPreviewClick = {[weak self] in
					guard let self else {return}
					if let fileModel = resultModel {
						self.showImageSummarizeData(model: fileModel)
					}
				}
				
				self.setInProcessCellCallBack(cell: cell1, model: model)
			}
			
			
			return cell
		}
		
		
		
		
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "MOSummarizeImageVideoFinishCell"
		)
		guard let cell else {
			
			return MOSummarizeImageVideoFinishCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeImageVideoFinishCell")
		}
		if let cell1 = cell as? MOSummarizeImageVideoFinishCell {
			cell1.scheduleVerticalTopView.isHidden = index.row == 0;
			cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1;
			cell1.configImageCellIsMine(dataModel: model)
			// 捕获必要的信息，避免闭包中直接引用model
			let resultModel = model.result?.first as? MOGetSummaryListItemResultModel
			cell1.didPreviewClick = {[weak self] in
				guard let self else {return}
				if let fileModel = resultModel {
					self.showImageSummarizeData(model: fileModel)
				}
			}
			
			self.setFinishCellCallBack(cell: cell1, model: model)
		}
		
		
		return cell
	}
	
	func getVideoCell(index:IndexPath) -> UITableViewCell {
		let model = dataList[index.row]
			
		if model.summarize_status == 1 || model.summarize_status == 3 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "MOSummarizeImageVideoInProcessCell")
			guard let cell else {
				
				return MOSummarizeImageVideoInProcessCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeImageVideoInProcessCell")
			}
			if let cell1 = cell as? MOSummarizeImageVideoInProcessCell {
				cell1.scheduleVerticalTopView.isHidden = index.row == 0;
				cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1;
				cell1.configVideoCell(dataModel: model)
				// 捕获必要的信息，避免闭包中直接引用model
				let resultModel = model.result?.first as? MOGetSummaryListItemResultModel
				cell1.didPreviewClick = {[weak self] in
					guard let self else {return}
					if let fileModel = resultModel {
						self.showVideoSummarizeData(model: fileModel)
					}
				}
				
				self.setInProcessCellCallBack(cell: cell1, model: model)
			}
			
			
			return cell
		}
		
		
		
		
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "MOSummarizeImageVideoFinishCell"
		)
		guard let cell else {
			
			return MOSummarizeImageVideoFinishCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOSummarizeImageVideoFinishCell")
		}
		if let cell1 = cell as? MOSummarizeImageVideoFinishCell {
			cell1.scheduleVerticalTopView.isHidden = index.row == 0;
			cell1.scheduleVerticalBottomView.isHidden = index.row == dataList.count - 1;
			cell1.configVideoCellIsMine(dataModel: model)
			// 捕获必要的信息，避免闭包中直接引用model
			let resultModel = model.result?.first as? MOGetSummaryListItemResultModel
			cell1.didPreviewClick = {[weak self] in
				guard let self else {return}
				if let fileModel = resultModel {
					self.showVideoSummarizeData(model: fileModel)
				}
			}
			
			self.setFinishCellCallBack(cell: cell1, model: model)
		}
		
		
		return cell
	}
	
}

extension MOMySummaryVC:@preconcurrency MOMyVoiceScheduleCellDelegate {
	func audioPlayerCell(_ cell: UITableViewCell, didUpdateProgress progress: Float, currentTime: TimeInterval) {
		let indexPath = tableView.indexPath(for: cell)
		
		return;
		// 如果当前已经有播放的Cell，且不是点击的这个Cell，停止它
		if currentPlayingIndex >= 0 && currentPlayingIndex != indexPath?.row {
			let cell = tableView.cellForRow(at: IndexPath(row: currentPlayingIndex, section: 0))
			if let cell1 = cell as? MOSummarizeAudioInProcessCell {
				cell1.stop()
			}
			
			if let cell1 = cell as? MOSummarizeAudioFinishCell {
				cell1.stop()
			}
		}
		
		// 更新当前播放的indexPath
		currentPlayingIndex = indexPath?.row ?? -1
		if let indexPath {
			let currentCell = tableView.cellForRow(at: indexPath)
			if let cell1 = currentCell as? MOSummarizeAudioInProcessCell {
				cell1.startPlaying()
			}
			
			if let cell1 = currentCell as? MOSummarizeAudioFinishCell {
				cell1.startPlaying()
			}
		}
		// 刷新表格以更新其他Cell的状态
		tableView.reloadData()
	}
	
	func audioPlayerCell(_ cell: UITableViewCell, didChangeState state: String) {
		let indexPath = tableView.indexPath(for: cell)
		if state == "Finished" || state.contains("Error") {
			currentPlayingIndex = -1
			tableView.reloadData()
		}
	}
	
	func audioPlayerCellDidRequestPlay(_ cell: UITableViewCell) {
		// 如果当前有正在播放的单元格且不是当前点击的单元格，停止播放
		let indexPath = tableView.indexPath(for: cell)
		if currentPlayingIndex >= 0,currentPlayingIndex != indexPath?.row {
			if let previousCell = tableView.cellForRow(at: IndexPath(row: currentPlayingIndex, section: 0)) as? MOSummarizeAudioInProcessCell {
				previousCell.stop()
			}
		}
		
		if currentPlayingIndex >= 0,currentPlayingIndex != indexPath?.row {
			if let previousCell = tableView.cellForRow(at: IndexPath(row: currentPlayingIndex, section: 0)) as? MOSummarizeAudioFinishCell {
				previousCell.stop()
			}
		}
		
		// 更新当前播放的 indexPath
		self.currentPlayingIndex = indexPath?.row ?? -1
		
		// 开始播放当前选中的单元格
		if let currentCell = cell as? MOSummarizeAudioInProcessCell {
			currentCell.startPlaying()
		}
		
		if let currentCell = cell as? MOSummarizeAudioFinishCell {
			currentCell.startPlaying()
		}
		
		// 刷新表格以更新其他单元格的状态
		tableView.reloadData()
	}
}

extension MOMySummaryVC:UITableViewDelegate,UITableViewDataSource {
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		
		WillEndDragging?(velocity)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let model = dataList[indexPath.row]
		let key = String(format: "%d", model.model_id)
		if model.cate == 1 {
			return getAudioCellHeight(model: model, cacheByKey: key)
		}
		
		if model.cate == 2 {
			return getPicTureCellHeight(model: model, cacheByKey: key)
		}
		if model.cate == 3 {
			return getTextCellHeight(model: model, cacheByKey: key)
		}
		
		//model.cate == 4
		return getVideoCellHeight(model: model, cacheByKey: key)
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		
		return CGFLOAT_MIN
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let vi = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return CGFLOAT_MIN
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		
		
		let vi = MOView()
		vi.backgroundColor = ClearColor
		return vi
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return dataList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = dataList[indexPath.row]
		
		if model.cate == 1 {
			return getAudioCell(index: indexPath)
		}
		
		if model.cate == 2 {
			return getPictureCell(index: indexPath)
		}
		if model.cate == 3 {
			return getTextCell(index: indexPath)
		}
		
		//model.cate == 4
		return getVideoCell(index: indexPath)
		
	}
	
	
}
