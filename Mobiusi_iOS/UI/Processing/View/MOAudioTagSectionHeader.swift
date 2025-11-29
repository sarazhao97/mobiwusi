//
//  MOAudioTagSectionHeader.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioTagSectionHeader:UICollectionReusableView {
    
    lazy var titleLable = {
        let lable = UILabel(text: "", textColor: Color626262!, font: MOPingFangSCMediumFont(12))
        return lable
    }()
    
    func setupUI(){
        self.addSubview(titleLable)
    }
    
    func setupConstraints(){
        titleLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.centerY.equalToSuperview().offset(5)
        }
    }
    
    func addSubviews(){
        setupUI()
        setupConstraints()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
