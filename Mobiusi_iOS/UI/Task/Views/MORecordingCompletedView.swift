//
//  MORecordingCompletedView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/5.
//

import Foundation
import AVFAudio
class MORecordingCompletedView: MOView {
    
    var didClickRerecordBtn:(()->Void)?
    var didClickNextBtn:(()->Void)?
    lazy var tipLabel:UILabel = {
        
        let label = UILabel(text: NSLocalizedString("录制完成，可点击试听", comment: ""), textColor: Color9B9B9B!, font: MOPingFangSCMediumFont(13))
        return label
    }()
    
    lazy var bottomView:MOView = {
        
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    lazy var playView:MOPlayRecordingView = {
        let vi = MOPlayRecordingView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    lazy var rerecordBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("重新录制", comment: ""), titleColor: Color9A1E2E!, bgColor: Color9A1E2E!.withAlphaComponent(0.2), font: MOPingFangSCBoldFont(16))
        btn.cornerRadius(QYCornerRadius.all, radius: 14)
        return btn
    }()
    
    lazy var nextBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("下一步", comment: ""), titleColor: WhiteColor!, bgColor: Color9A1E2E!, font: MOPingFangSCBoldFont(16))
        btn.cornerRadius(QYCornerRadius.all, radius: 14)
        return btn
    }()
    
    
    
    func setupUI(){
        self.addSubview(tipLabel)
        self.addSubview(playView)
        self.addSubview(bottomView)
        bottomView.addSubview(rerecordBtn)
        bottomView.addSubview(nextBtn)
    }
    
    func setupConstraints(){
        tipLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.top.equalToSuperview()
        }
        
        playView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.top.equalTo(tipLabel.snp.bottom).offset(20)
            make.height.equalTo(35)
        }
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(playView.snp.bottom).offset(26)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        rerecordBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(19)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
        }
        
        nextBtn.snp.makeConstraints { make in
            make.left.equalTo(rerecordBtn.snp.right).offset(17)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(19)
            make.height.equalTo(55)
            make.width.equalTo(rerecordBtn.snp.width)
        }
    }
    
    func addActions(){
        rerecordBtn.addTarget(self, action: #selector(rerecordBtnClick), for: UIControl.Event.touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func rerecordBtnClick(){
        
        didClickRerecordBtn?()
    }
    @objc func nextBtnClick(){
        
        didClickNextBtn?()
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        addActions()
        
    }
}
