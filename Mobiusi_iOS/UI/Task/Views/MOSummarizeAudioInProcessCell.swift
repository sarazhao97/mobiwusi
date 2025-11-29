//
//  MOSummarizeAudioInProcessCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/28.
//

import Foundation

@objcMembers
class MOSummarizeAudioInProcessCell: MOBaseSummarizeInProcessCell {
    var dataModel:MOGetSummaryListItemModel?
    weak var delegate:MOMyVoiceScheduleCellDelegate?
    var avPlayer:AVPlayer?
    var audioPlayer:AVAudioPlayer?
    var  audioDuration:TimeInterval?
    lazy var playerView = {
        let player = MOVoicePlayView()
        return player
    }()

    @objc func updatePlayingState(isPlaying:Bool) {
        if isPlaying {
            self.startPlaying()
        } else {
            self.stop()
        }
    }

    
    @objc func configAudioCell(dataModel:MOGetSummaryListItemModel){
        
        titleLabel.text = dataModel.title
        timeLabel.text = dataModel.create_time
        dataContentView.redDotView.isHidden = true
        self.dataModel = dataModel
        if dataModel.summarize_status == 1 {
            stateView.showInProcessStyle()
        } else {
            stateView.showProcessFailedStyle()
        }
        let  result = dataModel.result?.first as? MOGetSummaryListItemResultModel
        if let url =  result?.path {
            playerView.config(withUrl: url, andDuration: result?.duration ?? 0)
			audioDuration = TimeInterval(Int(result?.duration ?? 0))
        }
    }
    
    override func configCell() {
        
        attachmentFilesView.addSubview(playerView)
        playerView.playClick = { [weak self] boolValue in
            if boolValue {
                self?.play()
            } else {
                self?.stop()
            }
        }
        playerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(65)
        }
    }
}

// MARK: 音频播放
extension MOSummarizeAudioInProcessCell{
    
    override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            DispatchQueue.main.async {
                guard let avPlayer =  self.avPlayer else {return}
                if avPlayer.status == .readyToPlay {
                    self.delegate?.audioPlayerCell(self, didChangeState: "Ready")
                    
                }
                
                if avPlayer.status == .failed {
                    self.delegate?.audioPlayerCell(self, didChangeState: "Failed :\(String(describing: avPlayer.error?.localizedDescription))")
                }
                if avPlayer.status == .unknown {
                    self.delegate?.audioPlayerCell(self, didChangeState: "unknown")
                }
            }
        }
    }
    
    func play(){
        delegate?.audioPlayerCellDidRequestPlay(self)
    }
    func stop(){
        avPlayer?.pause()
        NotificationCenter.default.removeObserver(self, name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
        do {
            avPlayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        }catch{
            
        }
        playerView.playButton.isSelected = false
        avPlayer = nil
    }
    
    func updateNetworkAudioProgress(){
        
        guard let avPlayer,let audioDuration else {return}
        if avPlayer.rate > 0,avPlayer.error == nil {
            let playerCurrentTime = avPlayer.currentTime()
			let progress = CMTimeGetSeconds(playerCurrentTime) / (audioDuration/1000.0)
            playerView.updatePlayProgress(progress, andCurrentTime: Int(CMTimeGetSeconds(playerCurrentTime)))
            delegate?.audioPlayerCell(self, didUpdateProgress: Float(progress), currentTime: CMTimeGetSeconds(playerCurrentTime))
        }
    }
    
    func startPlaying(){
		guard let result = dataModel?.result?.first as? MOGetSummaryListItemResultModel else {return}
		if let tmpPlayer = avPlayer,tmpPlayer.status == .readyToPlay {
			return
		}
        if let url = URL(string: result.path ?? "") {
            avPlayer = AVPlayer.init(url: url)
            avPlayer?.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), context: nil)
            avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { [weak self] time in
                DispatchQueue.main.async {
                    self?.updateNetworkAudioProgress()
                }
                
            }
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinishPlaying), name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
            avPlayer?.play()
            playerView.playButton.isSelected = true
        }
        
        
    }
    
    @objc func playerItemDidFinishPlaying(){
        delegate?.audioPlayerCell(self, didChangeState: "Finished")
        playerView.endPlay()
        
    }
    
}

extension MOSummarizeAudioInProcessCell:@preconcurrency AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.delegate?.audioPlayerCell(self, didChangeState: "Finished")
        self.playerView.endPlay()
        self.stop()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        self.delegate?.audioPlayerCell(self, didChangeState: "Error: unkonwn error")
        self.playerView.endPlay()
        self.stop()
    }
}
