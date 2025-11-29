//
//  MOPlayRecordingView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/5.
//

import Foundation
class MOPlayRecordingView: MOView {
    var audioPalyer:AVAudioPlayer?
    var timer:Timer?
    lazy var playBtn:MOButton = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_sample_play"))
        btn.setImage(UIImage(namedNoCache: "icon_sample_pause"), for: UIControl.State.selected)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    lazy var greyImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_record_my_voice_playing_g")
        return imageView
    }()
    lazy var redImageMaskView:MOView = {
        let vi = MOView()
        vi.clipsToBounds = true
        return vi
    }()
    
    lazy var redImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_record_my_voice_playing_r")
        return imageView
    }()
    
    lazy var durationLabel:UILabel = {
        let label = UILabel(text: "00:00", textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(10))
        return label
    }()
    
    
    func setAudioPath(url:URL){
        audioPalyer = try? AVAudioPlayer(contentsOf: url)
        guard let audioPalyer else {return}
        audioPalyer.delegate = self
        let duration = audioPalyer.duration
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        durationLabel.text = String(format: "%02d:%02d", minutes,seconds)
        redImageMaskView.snp.remakeConstraints { make in
            make.left.equalTo(greyImageView.snp.left)
            make.top.equalTo(greyImageView.snp.top)
            make.bottom.equalTo(greyImageView.snp.bottom)
            make.width.equalTo(greyImageView.snp.width).multipliedBy(0)
        }
    }
    
    func setupUI(){
        self.addSubview(playBtn)
        self.addSubview(greyImageView)
        self.addSubview(redImageMaskView)
        redImageMaskView.addSubview(redImageView)
        self.addSubview(durationLabel)
        
    }
    
    func setupConstraints(){
        playBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            
        }
        playBtn.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        playBtn.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        greyImageView.snp.makeConstraints { make in
            make.left.equalTo(playBtn.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        redImageMaskView.snp.makeConstraints { make in
            make.left.equalTo(greyImageView.snp.left)
            make.top.equalTo(greyImageView.snp.top)
            make.bottom.equalTo(greyImageView.snp.bottom)
            make.width.equalTo(greyImageView.snp.width).multipliedBy(0)
        }
        redImageView.snp.makeConstraints { make in
            make.left.equalTo(greyImageView.snp.left)
            make.top.equalTo(greyImageView.snp.top)
            make.bottom.equalTo(greyImageView.snp.bottom)
            make.width.equalTo(greyImageView.snp.width)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.left.equalTo(greyImageView.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        durationLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        durationLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    
    func addActions(){
        playBtn.addTarget(self, action: #selector(playBtnClick), for: UIControl.Event.touchUpInside)
    }
    @objc func playBtnClick(){
        playBtn.isSelected = !playBtn.isSelected
        if playBtn.isSelected {
            guard let audioPalyer else {return}
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            audioPalyer.prepareToPlay()
            let sucess = audioPalyer.play();
            redImageMaskView.snp.remakeConstraints { make in
                make.left.equalTo(greyImageView.snp.left)
                make.top.equalTo(greyImageView.snp.top)
                make.bottom.equalTo(greyImageView.snp.bottom)
                make.width.equalTo(greyImageView.snp.width).multipliedBy(0)
            }
            if sucess {
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePlaybackProgress), userInfo: nil, repeats: true)
                timer?.fire()
            } else {
                playBtn.isSelected = false
            }
            return
        }
        timer!.invalidate()
        timer = nil
        audioPalyer?.stop()
        
    }

    @objc func updatePlaybackProgress() {
        guard let audioPalyer else {return}
//        let minutes = Int(audioPalyer.currentTime / 60)
//        let seconds = Int(audioPalyer.currentTime.truncatingRemainder(dividingBy: 60))
        var present = audioPalyer.currentTime/audioPalyer.duration
        if present > 1.0 {
            present = 1.0
        }
        
        DLog(String(format: "present:%f", present))
        redImageMaskView.snp.remakeConstraints { make in
            make.left.equalTo(greyImageView.snp.left)
            make.top.equalTo(greyImageView.snp.top)
            make.bottom.equalTo(greyImageView.snp.bottom)
            make.width.equalTo(greyImageView.snp.width).multipliedBy(present)
        }
        redImageView.setNeedsLayout()
    }
    

    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        addActions()
    }
}


extension MOPlayRecordingView:@preconcurrency AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playBtn.isSelected = false
        redImageMaskView.snp.remakeConstraints { make in
            make.left.equalTo(greyImageView.snp.left)
            make.top.equalTo(greyImageView.snp.top)
            make.bottom.equalTo(greyImageView.snp.bottom)
            make.width.equalTo(greyImageView.snp.width).multipliedBy(1)
        }
        timer!.invalidate()
        timer = nil
    }
}
