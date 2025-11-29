//
//  MOLinkRecognitionTopView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/27.
//

import Foundation
class MOLinkRecognitionTopView: MOView {
    
    lazy var textLabel = {
        let label = UILabel(text: "", textColor: Color5766E4!, font: MOPingFangSCMediumFont(14))
        label.numberOfLines = 3
		label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    func setupUI(){
        self.addSubview(textLabel)
        
    }
    
    func setupConstraints(){
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.right.equalToSuperview().offset(-21)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
    }
}
