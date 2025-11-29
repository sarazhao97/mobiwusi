//
//  MOAudioProcessingRecordVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/3.
//

import Foundation
class MOAudioProcessingRecordVC: MOBaseViewController {
	
	var pageIndex = 1
	var pageSize = 20
	var dataList:[MOAudioAnnotationItemModel] = []
	var playAudioIndex =  -1
	private var player: AVPlayer?
	private var playerItem: AVPlayerItem?
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString("加工记录", comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
		navBar.backgroundColor = WhiteColor
		return navBar
	}();
	
	@objc var tableView = {
		let table = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableView.Style.grouped)
		table.showsVerticalScrollIndicator = false
		table.separatorColor = ColorF2F2F2
//        table.separatorInset = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 29)
		table.estimatedRowHeight = 0;
		table.separatorStyle = .none
		table.estimatedSectionHeaderHeight = 0
		table.estimatedSectionFooterHeight = 0
		table.backgroundColor = ColorEDEEF5
		table.sectionIndexColor = ColorAFAFAF
		table.sectionIndexBackgroundColor = ClearColor
		table.sectionIndexTrackingBackgroundColor = ClearColor
		table.register(MOAudioProcessRecordCell.self, forCellReuseIdentifier: "MOAudioProcessRecordCell")
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
		return table
	}()
	
	func setupUI(){
		navBar.gobackDidClick = {
			MOAppDelegate().transition.popViewController(animated: true)
		}
		
		view.addSubview(navBar)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
			guard let self else {return}
			pageIndex = 1
			loadRequest()
		});
		tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: {[weak self] in
			guard let self else {return}
			pageIndex =  pageIndex + 1
			loadRequest()
		})
		tableView.mj_footer.isAutomaticallyHidden = true
		tableView.mj_header.beginRefreshing()
		view.addSubview(tableView)
		
	}
	
	func stupConstraints(){
		navBar.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalToSuperview()
		}
		tableView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.right.equalToSuperview()
			make.top.equalTo(navBar.snp.bottom)
			make.bottom.equalToSuperview()
		}
	}
	
	func loadRequest(){
		
		MONetDataServer.shared().annotationOrderList(withCateId: 1, page: self.pageIndex, limit: self.pageSize) { data in
			let list =  NSMutableArray.yy_modelArray(with: MOAudioAnnotationItemModel.self, json: data as Any) as? [MOAudioAnnotationItemModel]
			if self.pageIndex == 1 {
				self.dataList.removeAll()
				self.tableView.fd_keyedHeightCache.invalidateAllHeightCache()
				self.tableView.mj_header.endRefreshing()
			} else {
				self.tableView.mj_footer.endRefreshing()
			}
			if let list {
				self.dataList.append(contentsOf: list)
			}
			if list?.count ?? 0 < self.pageSize {
				self.tableView.mj_footer.endRefreshingWithNoMoreData()
			}
			
			self.tableView.reloadData()
			
		} failure: { error in
			self.showErrorMessage(error?.localizedDescription ?? "")
		} msg: { msg in
			self.showErrorMessage(msg)
		} loginFail: {
			DispatchQueue.main.async {
				self.hidenActivityIndicator()
			}
		}

	}
	
	
	func getLocationToAnnotationCreateOrder(index:Int) {
		
		if MOLocationManager.shared.latitude == 0 {
			self.showActivityIndicator()
			MOLocationManager.shared.onLocationUpdate = { [weak self] latitude,longitude,success in
				guard let self else {return}
				self.hidenActivityIndicator()
				annotationCreateOrder(index:index)
			}
			return
		}
		annotationCreateOrder(index:index)
	}
	
	func annotationCreateOrder(index:Int) {
		
		let model = dataList[index]
		self.showActivityIndicator()
		MONetDataServer.shared().annotationCreateOrder(withCateId: 1, dataId: model.user_data_id, taskId: model.task_id,lat: 0,lng: 0) { [self] annotation_order_id in
			self.hidenActivityIndicator()
//			let vc = MOPorcessingAudioVC(dataModel: model, annotationOrderId: annotation_order_id);
//			MOAppDelegate().transition.push(vc, animated: true)
			
		} failure: { error in
			self.hidenActivityIndicator()
			if let error = error {
				self.showErrorMessage(error.localizedDescription)
			}
			
		} msg: { msg in
			self.hidenActivityIndicator()
			if let msg {
				self.showErrorMessage(msg)
			}
		} loginFail: {
			self.hidenActivityIndicator()
		}
	}
	
	func goPorcessingAudioVC(index:Int){
		
		let model = dataList[index]
		if model.status == 4 {
			self.showMessage("请重新领取")
			MOAppDelegate().transition.popViewController(animated: true)
			return
		}
		var property:[String] = []
		if let bindProperty = model.property {
			
			for item in bindProperty{
				if let name = item.name {
					property.append(name)
				}
			}
		}

		let vc =  MOPorcessingAudioVC(result_id: model.result_id, meta_data_id: model.meta_data_id, taskTitle: model.task_title ?? "",property: property)
		vc.didSubmitData = {[weak self] in
			guard let self else {return}
			tableView.mj_header.beginRefreshing()
		}
		MOAppDelegate().transition.push(vc, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		stupConstraints()
	}
}


extension MOAudioProcessingRecordVC {
	func playAudio(url:String) {
		let audioUrl = NSURL(string: url)
		// 创建AVPlayerItem
		playerItem = AVPlayerItem(url: audioUrl! as URL)
		
		// 创建AVPlayer
		player = AVPlayer(playerItem: playerItem)
		
		// 监听播放状态
		observePlayerStatus()
		
		// 监听缓冲状态
		observeBufferStatus()
		
		// 开始播放
		player?.play()
	}
	
	func observePlayerStatus() {
			guard let playerItem = playerItem else { return }
			
			// 监听状态变化
		let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			guard let self else {return}
			DispatchQueue.main.async {
				self.startUpdatingCurrentTime()
			}
		}
			// 监听播放结束
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
	}
		
	private func observeBufferStatus() {
		guard let playerItem = playerItem else { return }
		
		// 监听加载状态
		playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context: nil)
	}
	
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == #keyPath(AVPlayerItem.status) {
			guard let status = change?[.newKey] as? AVPlayerItem.Status else { return }
			
			switch status {
			case .readyToPlay:
				print("准备播放")
			case .failed:
				print("播放失败")
			case .unknown:
				print("状态未知")
			@unknown default:
				break
			}
		} else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
			
			DispatchQueue.main.async {
				self.startUpdatingCurrentTime()
			}
			
			
		}
	}
	
	func startUpdatingCurrentTime(){
		// 计算缓冲进度
		guard let timeRanges = self.playerItem?.loadedTimeRanges,
			  let firstTimeRange = timeRanges.first as? CMTimeRange else { return }
		
//        let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(firstTimeRange.start, firstTimeRange.duration))
		let totalDuration = CMTimeGetSeconds(self.playerItem?.duration ?? CMTime.zero)
		
		let currentTime = CMTimeGetSeconds(self.playerItem?.currentTime() ?? CMTime.zero)
		let progress = Float64(currentTime) / totalDuration
		DLog("currentTime:\(currentTime)  progress:\(progress)")
		if self.playAudioIndex >= 0 && progress > 0 {
			if let cell = self.tableView.cellForRow(at: IndexPath(row: self.playAudioIndex, section: 0)) as? MOAudioProcessCell {
				cell.playView.updatePlayProgress(progress, andCurrentTime:Int(currentTime))
			}
		}
	}
		
	@objc func playerItemDidReachEnd(_ notification: Notification) {
		if let cell = self.tableView.cellForRow(at: IndexPath(row: self.playAudioIndex, section: 0)) as? MOAudioProcessCell {
			cell.playView.endPlay()
			
		}
		self.playAudioIndex = -1;
		self.tableView.reloadData()
	}
		
	func stop() {
		player?.pause()
		player = nil
		playerItem = nil
		
		NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
	}

}

extension MOAudioProcessingRecordVC:UITableViewDelegate,UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataList.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return CGFLOAT_MIN
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let model = dataList[indexPath.row]
		let height = tableView.fd_heightForCell(withIdentifier: "MOAudioProcessRecordCell", cacheBy: indexPath) { cell in
			
			if let cell1 = cell as? MOAudioProcessRecordCell {
				cell1.configCellWithModel(model: model)
			}
		}
		return height
	}

	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let model = dataList[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOAudioProcessRecordCell")
		guard let cell else {
			return MOAudioProcessRecordCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MOAudioProcessRecordCell")
		}
		if let cell1 = cell as? MOAudioProcessRecordCell {
			cell1.configCellWithModel(model: model)
			cell1.scheduleVerticalTopView.isHidden = indexPath.row == 0
			cell1.scheduleVerticalBottomView.isHidden = dataList.count - 1 == indexPath.row
			cell1.playView.playClick = {[weak self] boolValue in
				guard let self else {return}
				if boolValue, let path =  model.path {
					self.playAudioIndex = indexPath.row
					playAudio(url: path)
				}
			}
			if indexPath.row != self.playAudioIndex {
				cell1.playView.endPlay()
			}
			cell1.didMsgBtnClick = {[weak self] in
				guard let self else {return}
				self.goPorcessingAudioVC(index: indexPath.row)
			}
			cell1.stateView.didClick = {[weak self] in
				guard let self else {return}
				self.goPorcessingAudioVC(index: indexPath.row)
			}
		}
		
		return cell
	}
	
}
