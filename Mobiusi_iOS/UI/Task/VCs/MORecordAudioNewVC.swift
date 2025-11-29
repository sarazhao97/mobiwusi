//
//  MORecordAudioNewVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/5.
//

import Foundation
public class MORecordAudioNewVC: MOBaseViewController {
    
    lazy var bgView:MOHorizontalGradientView = {
        
        let vi = MOHorizontalGradientView(colors: [ColorFFACB7!,ColorEDEEF5!])
        return vi
    }()
    
    lazy var nextBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("下一步", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(12))
        btn.cornerRadius(QYCornerRadius.all, radius: 10)
        btn.fixAlignmentBUG()
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return btn
    }()
    private lazy var navBar:MONavBarView = {
        let navBar = MONavBarView()
        navBar.titleLabel.text = NSLocalizedString("", comment: "")
        
        navBar.backBtn.fixAlignmentBUG()
        navBar.backBtn.setImage(UIImage())
        navBar.backBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        navBar.backBtn.setTitle(NSLocalizedString("取消", comment: ""), titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))

        return navBar
    }();
    
    
    lazy var topView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_microphone")
        return imageView
    }()
    
    lazy var durationLabel:UILabel = {
        
        let label = UILabel(text: "0s", textColor: BlackColor, font: MOPingFangSCMediumFont(13))
        return label
    }()
    
    lazy var tipLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("录音时长不能低于5s", comment: ""), textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(13))
        return label
    }()
    
    lazy var bottomView:MOStartRecordingView = {
        let vi = MOStartRecordingView()
        return vi
    }()
    
    lazy var bottomCompletedView:MORecordingCompletedView = {
        let vi = MORecordingCompletedView()
        return vi
    }()
    
    lazy var countDownView:MOSoundRecordCountdownView = {
        
        let vi = MOSoundRecordCountdownView()
        return vi
    }()
    
    lazy var countDownValue = 0.0
    
    lazy var recorder:AVAudioRecorder? = {
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey:16,
            AVLinearPCMIsFloatKey:false,
            AVLinearPCMIsBigEndianKey:false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // 指定音频文件的保存路径
        let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first!
        let customDirectory = documentsDirectory.appendingPathComponent("Mobiwusi/recordTask")
        do {
            try FileManager.default.createDirectory(at: customDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            DLog("创建目录失败: \(error.localizedDescription)")
        }
        let audioFileName = UUID().uuidString + ".wav"
        let audioFileURL = customDirectory.appendingPathComponent(audioFileName)
        let re =  try? AVAudioRecorder.init(url: audioFileURL, settings: recordingSettings)
        re?.isMeteringEnabled = true
        return re
        
    }()
    
    var meterTimer:Timer?
    
    func setupUI(){
        view.addSubview(bgView)
        
        navBar.rightItemsView.addArrangedSubview(self.nextBtn)
        navBar.gobackDidClick = {[weak self] in
            guard let self else {return}
            self.goBack()
        }
        view.addSubview(navBar)
        view.addSubview(topView)
        view.addSubview(durationLabel)
        view.addSubview(tipLabel)
        bottomView.didClickBtn = {[weak self] (isSelected)in
            guard let self else {return}
            if isSelected {
                self.startRecording()
                return
            }
            self.stopRecording()
        }
        view.addSubview(bottomView)
        
        bottomCompletedView.didClickRerecordBtn = {[weak self] in
            self?.showInitializationView()
        }
        bottomCompletedView.didClickNextBtn = {[weak self] in
            self?.goUploadVC()
        }
        view.addSubview(bottomCompletedView)
        countDownView.isHidden = true
        countDownView.complete = {[weak self] in
            guard let self else {return}
            self.countDownView.isHidden = true
        }
        view.addSubview(countDownView)
        
        self.showInitializationView()
        
    }
    func setupConstraints(){
        
        self.nextBtn.snp.makeConstraints { make in
            make.height.equalTo(26)
        }
        navBar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().multipliedBy(0.75)
        }
        
        topView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom).offset(60)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(60)
        }
        
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(durationLabel.snp.bottom).offset(7)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bottomCompletedView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        countDownView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func addActions(){
        
        self.nextBtn.addTarget(self, action: #selector(nextBtnClick), for: UIControl.Event.touchUpInside)
    }
    @objc func nextBtnClick(){
        
        meterTimer?.invalidate()
        meterTimer = nil
        bottomCompletedView.playView.timer?.invalidate()
        bottomCompletedView.playView.timer = nil
        self.goUploadVC()
    }
    
    func startRecording() {
        showInitializationView()
        
        
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        if status == .denied {
            bottomView.recordingStatusReset()
            let alertVC = UIAlertController.init(title: NSLocalizedString("请在\"设置－Mobiwusi\"中打开麦克风权限", comment: ""), message: nil, preferredStyle: UIAlertController.Style.alert)
            let setupAction = UIAlertAction(title: NSLocalizedString("去设置", comment: ""), style: UIAlertAction.Style.default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            alertVC.addAction(setupAction)
            self.present(alertVC, animated: true)
            return
        }
        if status == .notDetermined {
            
            DispatchQueue.global().async {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio) { _ in
				}
            }
            bottomView.recordingStatusReset()
            return
        }
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record,options: AVAudioSession.CategoryOptions.allowBluetooth)
        try? AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
        try? AVAudioSession.sharedInstance().setPreferredSampleRate(44100)
        try? AVAudioSession.sharedInstance().setActive(true)
        
//        countDownView.isHidden = false
//        countDownView.start()
        
        
        recorder?.prepareToRecord()
        recorder?.record()
        
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {[weak self] timer in
            guard let self else { return}
            
            DispatchQueue.main.async {
                self.countDownValue = self.countDownValue + 0.1
                if self.countDownValue < 1 {
                    self.durationLabel.text = "0s"
                } else {
                    self.durationLabel.text = "\(UInt32(self.countDownValue))s"
                }
                
                self.updateMeter()
            }
            
        })
        meterTimer?.fire()
        
    }
    
     @objc func updateMeter(){
        guard let recorder else {return}
        recorder.updateMeters()
        let decibels = recorder.averagePower(forChannel: 0)
        var normalizedValue = (decibels + 160.0)/160.0
        normalizedValue = max(0.0, min(1.0, normalizedValue))
         DLog("%f ======\(normalizedValue)")
         bottomView.animationView.updateMeters(CGFloat(normalizedValue) * 0.5)
    }
    
    func stopRecording(){
        meterTimer?.invalidate()
        meterTimer = nil
        guard let recorder else {return}
        if recorder.isRecording {
            
            if self.countDownValue < 5 {
                recorder.stop()
                self.showMessage(NSLocalizedString("录音时长不能低于5s", comment: ""))
                self.showInitializationView()
                return
            }
            
            self.showProgress(withMessage: NSLocalizedString("保持静音，录音处理中", comment: ""))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0, execute: DispatchWorkItem(block: {
                recorder.stop()
                self.bottomCompletedView.playView.setAudioPath(url: recorder.url)
                self.showRecordCompleteView()
                
            }))
            
            
        }
    }
    
    
    func showRecordCompleteView(){
        self.bottomView.isHidden = true
        self.bottomCompletedView.isHidden = false
        self.tipLabel.isHidden = true
        self.durationLabel.isHidden = true
        self.nextBtn.isHidden = false
    }
    
    func showInitializationView(){
        self.countDownValue = 0
        self.durationLabel.text = "0s"
        self.durationLabel.isHidden = false
        self.bottomView.isHidden = false
//        self.bottomView.recordingStatusReset()
        self.bottomCompletedView.isHidden = true
        self.tipLabel.isHidden = false
        self.nextBtn.isHidden = true
    }
    
    func goUploadVC(){
        DLog("\(self.presentingViewController)")
        if let presentingViewController = self.presentingViewController {
            self.dismiss(animated: false)
            if let audioIrl = recorder?.url {
                presentingViewController.present(MOUploadAuidoDataVC.createAlertStyle(audioUrl:audioIrl), animated: true) {
                }
            }
            
        }
        
                     
    }
    
    @objc public class func createAlertStyle() ->MORecordAudioNewVC{
        let vc = MORecordAudioNewVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
    
    
    public override func goBack() {
        meterTimer?.invalidate()
        meterTimer = nil
        bottomCompletedView.playView.timer?.invalidate()
        bottomCompletedView.playView.timer = nil
        self.dismiss(animated: true)
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addActions()
        
    }
}
