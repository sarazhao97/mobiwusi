//
//  MOStartRecordingView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/5.
//

import Foundation
class MOStartRecordingView: MOView {
    
    var didClickBtn:((_ isSelected:Bool)->Void)?
    
    lazy var animationView:MOMicAnimationView = {
        let vi = MOMicAnimationView()
        vi.borderColor = ColorEDDEE0!
        vi.innercircleColor = ColorEDDEE0!
        return vi
    }()
    
    lazy var recordBtn:MOButton = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_record_task_record"))
        btn.setImage(UIImage(namedNoCache: "icon_record_task_pause_r"), for: UIControl.State.selected)
        return btn
    }()
    lazy var tipLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("点击录制", comment: ""), textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(13))
        return label
    }()
    func setupUI(){
        self.addSubview(animationView)
        self.addSubview(recordBtn)
        self.addSubview(tipLabel)
    }
    
    func setupConstraints(){
        recordBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            
        }
        
        animationView.snp.makeConstraints { make in
            make.centerX.equalTo(recordBtn.snp.centerX)
            make.centerY.equalTo(recordBtn.snp.centerY)
            make.height.equalTo(recordBtn.snp.height)
            make.width.equalTo(recordBtn.snp.width)
            
        }
        
        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordBtn.snp.bottom).offset(7)
            make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
        }
    }
    
    
    func setAtcion() {
        recordBtn.addTarget(self, action: #selector(recordBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func recordBtnClick(){
        recordBtn.isSelected = !recordBtn.isSelected
        guard let didClickBtn else {return}
        didClickBtn(recordBtn.isSelected)
    }
    
    func recordingStatusReset(){
        recordBtn.isSelected = false
    }
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
        setAtcion()
        
    }
}
