//
//  MOBankWithdrawItemView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/7.
//

import Foundation
class MOBankWithdrawItemView: MOView {
    public lazy var titleLabel:UILabel = {
        let Label:UILabel = UILabel(text: "", textColor: Color959998!, font: MOPingFangSCMediumFont(12))
        return Label
    }()
    
    public lazy var textFiledContentView:MOView = {
        let vi:MOView = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 10)
        return vi
    }()
    
    public lazy var textFiled:UITextField = {
        let tf:UITextField = UITextField()
        tf.backgroundColor = ClearColor
        return tf
    }()
    
    override func addSubViews(inFrame frame: CGRect) {
         
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
        }
        
        
        self.addSubview(textFiledContentView)
        textFiledContentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(55)
            make.bottom.equalToSuperview()
        }
        
        textFiledContentView.addSubview(textFiled)
        textFiled.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21.5)
            make.right.equalToSuperview().offset(-21.5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
