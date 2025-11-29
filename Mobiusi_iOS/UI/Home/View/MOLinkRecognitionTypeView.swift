//
//  MOLinkRecognitionTypeView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MOLinkRecognitionTypeView:MOView {
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    var dataModel:MOParsePasteboardContentModel?
    var didClickData:((_ index:Int)->Void)?
    lazy var collectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH), collectionViewLayout: flowLayout)
        return collection
    }()
    
    func setupUI(){
        self.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MOLinkRecognitionVideoCell.self, forCellWithReuseIdentifier: "MOLinkRecognitionVideoCell")
        collectionView.register(MOTextFillTaskUploadFileCell.self, forCellWithReuseIdentifier: "MOTextFillTaskUploadFileCell")
        collectionView.register(MOLinkRecognitionAudioCell.self, forCellWithReuseIdentifier: "MOLinkRecognitionAudioCell")
        
        collectionView.observeValue(forKeyPath: "contentSize") { [weak self]dict, object in
            let size:CGSize = dict["new"] as! CGSize
            guard let self else {return}
            if size.height != self.collectionView.bounds.height {
                
                self.collectionView.snp.remakeConstraints{ make in
                    make.height.equalTo(size.height)
                    make.left.equalToSuperview().offset(19)
                    make.right.equalToSuperview().offset(-19)
                    make.top.equalToSuperview().offset(23)
                    make.bottom.equalToSuperview().offset(-23)
                }
            }
        }
        
    }
    
    func setupConstraints(){
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(19)
            make.right.equalToSuperview().offset(-19)
            make.top.equalToSuperview().offset(23)
            make.bottom.equalToSuperview().offset(-23)
        }
    }
    
    func configView(dataModel:MOParsePasteboardContentModel) {
        self.dataModel = dataModel
        self.collectionView.reloadData()
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
        
    }
}

// MARK: 音频播放
extension MOLinkRecognitionTypeView {
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
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
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
        
        let bufferedDuration = CMTimeGetSeconds(CMTimeAdd(firstTimeRange.start, firstTimeRange.duration))
        let totalDuration = CMTimeGetSeconds(self.playerItem?.duration ?? CMTime.zero)
        var  progress = bufferedDuration / totalDuration
        var currentTime = Int(CMTimeGetSeconds(self.playerItem?.currentTime() ?? CMTime.zero))
        DLog("currentTime:\(currentTime)")
        if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? MOLinkRecognitionAudioCell {
            if progress.isNaN {
                progress = 0
            }
            currentTime = -currentTime
//            cell.playView.updatePlayProgress(progress, andCurrentTime:Int(currentTime))
            
            
        }
    }
        
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? MOLinkRecognitionAudioCell {
            cell.playView.endPlay()
            
        }
        self.collectionView.reloadData()
    }
        
    func stop() {
        player?.pause()
        player = nil
        playerItem = nil
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

}

extension MOLinkRecognitionTypeView:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if dataModel?.cate == 1 || dataModel?.cate == 3 {
            return CGSize(width: collectionView.bounds.width , height: 44)
        }
        
        
        return CGSize(width: 115, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.dataModel != nil) ? 1: 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if self.dataModel?.cate == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOLinkRecognitionAudioCell", for: indexPath)
            
            if let cell1 = cell as? MOLinkRecognitionAudioCell,let dataModel = self.dataModel {
                if let url = URL(string: dataModel.resource_url ?? "") {
					cell1.playView.config(withUrl: url.absoluteString, andDuration: dataModel.duration)
                    cell1.playView.playClick = { [weak self]boolValue in
                        guard let self else {return}
                        if boolValue {
                            self.playAudio(url: url.absoluteString)
                        } else {
                            self.stop()
                        }
                    }
                    
                }
                
            }
            return cell
        }
        
        if self.dataModel?.cate == 2 {
            
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOLinkRecognitionVideoCell", for: indexPath)
            if let cell1 = cell as? MOLinkRecognitionVideoCell,let dataModel = self.dataModel {
                cell1.playImage.isHidden = true
                cell1.configCell(dataModel: dataModel)
            }
            return cell
            
            
        }
        
        if self.dataModel?.cate == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOTextFillTaskUploadFileCell", for: indexPath)
            if let cell1 = cell as? MOTextFillTaskUploadFileCell {
                cell1.deleteBtn.isHidden = true
                cell1.failurePromptView.isHidden = true
                cell1.fileView.fileNameLabel.text = dataModel?.extract_content != nil ? "\(dataModel?.title ?? "").txt":dataModel?.file_name
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MOLinkRecognitionVideoCell", for: indexPath)
        if let cell1 = cell as? MOLinkRecognitionVideoCell ,let dataModel = self.dataModel{
            cell1.playImage.isHidden = false
            cell1.configCell(dataModel: dataModel)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        didClickData?(indexPath.row)
    }

}

class MOLinkRecognitionVideoCell:UICollectionViewCell {
    
    lazy var videoImage = {
        let imageView = UIImageView()
        imageView.cornerRadius(QYCornerRadius.all, radius: 10)
        imageView.backgroundColor = Color9B9B9B
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var playImage = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_data_video_pause")
        return imageView
    }()
    
    func setupUI(){
        contentView.addSubview(videoImage)
        contentView.addSubview(playImage)
    }
    
    func setupConstraints(){
        videoImage.snp.makeConstraints { make in
            make.edges.equalToSuperview().offset(1)
        }
        
        playImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func addSubviews(){
        setupUI()
        setupConstraints()
    }
    
    func configCell(dataModel:MOParsePasteboardContentModel) {
        if dataModel.cate == 4,let url =  dataModel.preview_url {
            videoImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(namedNoCache: ""), context: nil);
        }
        if dataModel.cate == 2,let url =  dataModel.resource_url {
            videoImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(namedNoCache: ""), context: nil);
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MOLinkRecognitionAudioCell:UICollectionViewCell {
    
    lazy var playView = {
        let vi  = MOVoicePlayView()
        return vi
    }()
    func setupUI(){
        contentView.addSubview(playView)
    }
    
    func setupConstraints(){
        
        playView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addSubviews(){
        setupUI()
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


