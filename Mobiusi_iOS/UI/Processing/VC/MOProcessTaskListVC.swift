//
//  MOProcessTaskListVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/13.
//

import UIKit

@objc
class MOProcessTaskListVC: MOBaseViewController {

	
	var parentScrollView:UIScrollView?
	var taskDetail:MOTaskDetailNewModel
	var questionDetail:MORecordTaskDetailModel?
	var isManualLoading = false
	var playAudioIndex =  -1
	private var player: AVPlayer?
	private var playerItem: AVPlayerItem?
	
	private lazy var navBar:MONavBarView = {
		let navBar = MONavBarView()
		navBar.titleLabel.text = NSLocalizedString("加工音频", comment: "")
		navBar.backBtn.setImage(UIImage(namedNoCache: "icon_nav_back_b"))
		return navBar
	}();
	
	@objc var tableView = {
		let table = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: UITableView.Style.grouped)
		table.showsVerticalScrollIndicator = false
		table.separatorColor = ColorF2F2F2
		table.estimatedRowHeight = 0;
		table.separatorStyle = .none
		table.estimatedSectionHeaderHeight = 0
		table.estimatedSectionFooterHeight = 0
		table.backgroundColor = ColorEDEEF5
		table.sectionIndexColor = ColorAFAFAF
		table.sectionIndexBackgroundColor = ClearColor
		table.sectionIndexTrackingBackgroundColor = ClearColor
		table.register(MOAudioQuestionProcessStateCell.self, forCellReuseIdentifier: "MOAudioQuestionProcessStateCell")
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
		view.addSubview(tableView)
		tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
			guard let self else {return}
		   loadRequest()
		});
		tableView.delegate = self
		tableView.dataSource = self
		tableView.mj_header.beginRefreshing()
	}
	
	func setupConstraints(){
		
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
		
		MONetDataServer.shared().getUserTaskTopic(withTaskId: self.taskDetail.task_id, user_task_id: self.taskDetail.user_task_id, task_status: self.taskDetail.task_status.intValue, topic_type: self.taskDetail.topic_type) { dict in
			let  questionDetail = MORecordTaskDetailModel.yy_model(withJSON: dict as Any)
			var dataList:[MOTaskQuestionModel] = []
			if let data = dict?["data"] as? NSArray {
				for item in data {
					if let itemModel = MOTaskQuestionModel.yy_model(withJSON: item) {
						dataList.append(itemModel)
					}
					
				}
			}
			questionDetail?.data = dataList
			self.questionDetail = questionDetail
			self.tableView.mj_header.endRefreshing()
			self.tableView.reloadData()
			
		} failure: { error in
			self.showErrorMessage(error?.localizedDescription)
		} msg: { msg in
			self.showErrorMessage(msg)
		} loginFail: {
			DispatchQueue.main.async {
				self.hidenActivityIndicator()
			}
		}

	}
	
	func goProcessAudio(index:Int) {
		let model = self.questionDetail?.data[index]
		
		
		
		if let audioData = model?.audio_data.first,let model_id = model?.model_id {
			var property:[String] = []
			if let bindProperty = audioData.property as? [MOTaskQuestionModelProperty] {
				
				for item in bindProperty{
					if let name = item.name {
						property.append(name)
					}
				}
			}
			
			let vc =  MOPorcessingAudioVC(result_id: model_id, meta_data_id: audioData.model_id, taskTitle: model?.task_title ?? "", property: property)
			vc.didSubmitData = {[weak self] in
				guard let self else {return}
				tableView.mj_header.beginRefreshing()
			}
			MOAppDelegate().transition.push(vc, animated: true)
		}
		
	}
	
	@objc public init(taskDetail:MOTaskDetailNewModel) {
		self.taskDetail = taskDetail
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupConstraints()
		
	}
    

}
extension MOProcessTaskListVC {
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

extension MOProcessTaskListVC:UITableViewDelegate,UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.questionDetail?.data.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let model = self.questionDetail?.data[indexPath.row]
		let height = tableView.fd_heightForCell(withIdentifier: "MOAudioQuestionProcessStateCell", cacheBy: indexPath) { cell in
			if let cell1 = cell as? MOAudioQuestionProcessStateCell,let audioData = model?.audio_data.first {
				cell1.configCell(questionModel: audioData, taskTitle: model?.task_title)
			}
		}
		return height;
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return CGFLOAT_MIN
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "MOAudioQuestionProcessStateCell")
		let model = self.questionDetail?.data[indexPath.row]
		if let cell1 = cell as? MOAudioQuestionProcessStateCell,let audioData = model?.audio_data.first {
			cell1.configCell(questionModel: audioData, taskTitle: model?.task_title)
			cell1.playView.playClick = {[weak self] boolValue in
				guard let self else {return}
				if boolValue, let path =  audioData.url {
					self.playAudioIndex = indexPath.row
					playAudio(url: path)
				}
			}
			
			cell1.stateView.didClick = {[weak self] in
				guard let self else {return}
				self.goProcessAudio(index: indexPath.row)
			}
			
			cell1.didClickGoProcess = {[weak self] in
				guard let self else {return}
				self.goProcessAudio(index: indexPath.row)
				
			}
			
			if indexPath.row != self.playAudioIndex {
				cell1.playView.endPlay()
			}
		}
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		if velocity.y > 0 {
			parentScrollView?.setContentOffset(CGPoint(x: 0, y: 262), animated: true)
		}
		
		if velocity.y < 0 && scrollView.contentOffset.y <= 0{
			parentScrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		}
	}
	
	
}
