//
//  MOAudioProcessListVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/23.
//

import Foundation
@objcMembers
class MOAudioProcessListVC:MOBaseViewController {
    
    var pageIndex = 1
    var pageSize = 20
    var parentScrollView:UIScrollView?
    var dataList:[MOAudioAnnotationItemModel] = []
    var isManualLoading = false
    var playAudioIndex =  -1
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
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
        table.register(MOAudioProcessCell.self, forCellReuseIdentifier: "MOAudioProcessCell")
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
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            guard let self else {return}
            pageIndex = 1
			getLocationToGetDataList()
        });
        tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: {[weak self] in
            guard let self else {return}
            pageIndex =  pageIndex + 1
			getLocationToGetDataList()
        })
        tableView.mj_footer.isAutomaticallyHidden = true
        
        if isManualLoading {
            tableView.mj_header.beginRefreshing()
        }
    }
    
    func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
	
	
	func getLocationToGetDataList() {
		
		if MOLocationManager.shared.latitude == 0 {
			self.showActivityIndicator()
			MOLocationManager.shared.onLocationUpdate = { [weak self] latitude,longitude,success in
				guard let self else {return}
				self.hidenActivityIndicator()
				loadRequest()
			}
			return
		}
		loadRequest()
	}
    
    func loadRequest(){
        
		MONetDataServer.shared().annotation(withCateId: 1,lat:MOLocationManager.shared.latitude,lng: MOLocationManager.shared.longitude , page: pageIndex, limit: pageSize) { [weak self] dict in
            guard let self else {return}
            let list =  NSMutableArray.yy_modelArray(with: MOAudioAnnotationItemModel.self, json: dict as Any) as? [MOAudioAnnotationItemModel]
            
            if pageIndex == 1 {
                dataList.removeAll()
                tableView.fd_keyedHeightCache.invalidateAllHeightCache()
                tableView.mj_header.endRefreshing()
            } else {
                tableView.mj_footer.endRefreshing()
            }
            if let list {
                dataList.append(contentsOf: list)
            }
            if list?.count ?? 0 < 20 {
                tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            
            tableView.reloadData()
        } failure: { [weak self] error in
            guard let self else {return}
            self.showErrorMessage(error?.localizedDescription ?? "")
        } msg: {[weak self] msg in
            guard let self else {return}
            self.showErrorMessage(msg ?? "")
        } loginFail: {
            
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
		MONetDataServer.shared().annotationCreateOrder(withCateId: 1, dataId: model.model_id, taskId: model.task_id,lat:MOLocationManager.shared.latitude,lng: MOLocationManager.shared.longitude) { [self] annotation_order_id in
			self.hidenActivityIndicator()
			model.user_data_id = model.model_id
			let vc = MOPorcessingAudioVC(result_id: 0, meta_data_id: 0, taskTitle: "",property: []);
			dataList.remove(at: index)
			self.tableView.reloadData()
			MOAppDelegate().transition.push(vc, animated: true)
			
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
    
    public func manualLoadingIfLoad(){
        if self.isViewLoaded {
            tableView.mj_header.beginRefreshing()
        } else {
            isManualLoading = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
}

// MARK: - 音视频播放处理
extension MOAudioProcessListVC {
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

extension MOAudioProcessListVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let model = dataList[indexPath.row]
        let height = tableView.fd_heightForCell(withIdentifier: "MOAudioProcessCell", cacheBy: indexPath) { cell in
            
            if let cell1 = cell as? MOAudioProcessCell {
                cell1.configCellWithModel(model: model)
            }
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MOAudioProcessCell")
        let model = dataList[indexPath.row]
        if let cell1 = cell as? MOAudioProcessCell {
            cell1.configCellWithModel(model: model)
            cell1.playView.playClick = {[weak self] boolValue in
                guard let self else {return}
                if boolValue, let path =  model.path {
                    self.playAudioIndex = indexPath.row
                    playAudio(url: path)
                }
            }
			cell1.didMsgBtnClick = {[weak self] in
				guard let self else {return}
				getLocationToAnnotationCreateOrder(index: indexPath.row)
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


