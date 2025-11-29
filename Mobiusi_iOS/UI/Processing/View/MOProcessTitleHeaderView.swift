//
//  MOProcessTitleHeaderView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/19.
//

import Foundation
class MOProcessTitleHeaderView: MOView {
    
    lazy var titleLabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(18))
        label.numberOfLines = 0
		label.lineBreakMode = .byCharWrapping
        return label
    }()
    lazy var subTitleLabel = {
        let label = UILabel(text: "", textColor: Color626262!, font: MOPingFangSCMediumFont(10))
        return label
    }()
    
    func setupUI(){
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
    }
    
    func setupConstraints(){
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
    }
}
