//
//  MOUnbindAlertTipVC.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/7.
//

import Foundation

class MOUnbindAlertTipVC: MOBaseViewController {
    
    public var makeSureClick:((_ alertVC:MOUnbindAlertTipVC)->Void)?
    private lazy var centerContenView:MOView = {
        
        let vi:MOView = MOView();
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
        
    }()
    
    public lazy var coloseBtn:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.setImage(UIImage.init(namedNoCache: "icon_pop_alert_close"))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
        
    }()
    
    public lazy var alertTitleLabel:UILabel = {
        
        let label:UILabel = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(18));
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    public lazy var alertTextLabel:UILabel = {
        
        let label:UILabel = UILabel(text: "", textColor: Color959998!, font: MOPingFangSCMediumFont(13));
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    public lazy var bottomBtn:MOButton = {
        
        let btn:MOButton = MOButton();
        btn.setTitle(NSLocalizedString("解除绑定", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(16))
        btn.cornerRadius(QYCornerRadius.all, radius: 14)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        return btn
        
    }()
    
    private func setupUI() {
        view.backgroundColor = BlackColor.withAlphaComponent(0.6)
        
        view.addSubview(centerContenView)
        
        centerContenView.addSubview(coloseBtn)
        centerContenView.addSubview(alertTitleLabel)
        centerContenView.addSubview(alertTextLabel)
        centerContenView.addSubview(bottomBtn)
    }
    
    private func setupConstraints(){
        centerContenView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(37)
            make.right.equalToSuperview().offset(-37)
            make.centerY.equalToSuperview()
        }
        
        coloseBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(17)
        }
        
        alertTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.left.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-22)
        }
        
        alertTextLabel.snp.makeConstraints { make in
            make.top.equalTo(alertTitleLabel.snp.bottom).offset(11)
            make.left.equalToSuperview().offset(37)
            make.right.equalToSuperview().offset(-37)
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.top.equalTo(alertTextLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-22)
            make.height.equalTo(49)
            make.bottom.equalToSuperview().offset(-35)
        }
    }
    
    private func setupActions() {
        
        bottomBtn.addTarget(self, action: #selector(bottomBtnClick), for: UIControl.Event.touchUpInside)
        coloseBtn.addTarget(self, action: #selector(coloseBtnClick), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc func bottomBtnClick() {
        
        makeSureClick?(self)
        self.dismiss(animated: true)
    }
    
    @objc func coloseBtnClick() {
        
        self.dismiss(animated: true)
    }
    
    public class func showAlert(title:String?,text:String,makeSure:( (_ alertVC:MOUnbindAlertTipVC)->Void)? = nil ) ->MOUnbindAlertTipVC {
        
        let vc:MOUnbindAlertTipVC = MOUnbindAlertTipVC();
        vc.alertTitleLabel.text = title
        vc.alertTextLabel.text = text
        vc.makeSureClick = makeSure
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        
        
    }
}
