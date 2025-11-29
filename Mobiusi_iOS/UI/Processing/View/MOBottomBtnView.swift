//
//  MOBottomBtnView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOBottomBtnView :MOView {
    var didClick:(()->Void)?
    lazy var bottomBtn = {
        let btn = MOButton()
        return btn
    }()
    
    func setupUI(){
        self.addSubview(bottomBtn)
    }
    
    func setupConstraints(){
        
        bottomBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.right.equalToSuperview().offset(-23)
            make.top.equalToSuperview().offset(19)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().offset(Bottom_SafeHeight > 0 ? -Bottom_SafeHeight:-20)
        }
    }
    
    func addAction(){
        bottomBtn.addTarget(self, action: #selector(bottomBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func bottomBtnClick(){
        
        didClick?()
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
        addAction()
    }
    
}
