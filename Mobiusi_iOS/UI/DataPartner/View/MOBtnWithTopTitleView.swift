//
//  MOBtnWithTopTitleView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/28.
//

import Foundation
class MOBtnWithTopTitleView: MOView {
    
    var didCick:(()->Void)?
    lazy var bottomBtn:MOButton = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("上传认证", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(16))
        btn.cornerRadius(QYCornerRadius.all, radius: 14)
        return btn
    }()
    
    lazy var topBtn:MOButton = {
        let btn = MOButton()
        btn.setImage(UIImage.init(namedNoCache: "icon_secure_encryption"))
        btn.setTitle(NSLocalizedString("MOBIUSI将对信息智能加密，实时保障信息安全", comment: ""), titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
        btn.titleLabel?.numberOfLines = 0
        return btn
    }()
    
    func setupUI(){
        self.addSubview(topBtn)
        self.addSubview(bottomBtn)
    }
    
    func setupConstraints(){
        
        topBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(20)
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(topBtn.snp.bottom).offset(20)
            make.height.equalTo(49)
            make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20 )
        }
    }
    
    func addActions(){
        bottomBtn.addTarget(self, action: #selector(bottomBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func bottomBtnClick(){
        
        didCick?()
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        addActions()
    }
}
