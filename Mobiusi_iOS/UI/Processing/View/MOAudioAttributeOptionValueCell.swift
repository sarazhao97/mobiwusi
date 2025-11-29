//
//  MOAudioAttributeOptionValueCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioAttributeOptionValueCell: MOTableViewCell {
    var titleLabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(15))
        return label
    }()
    
    var rightImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_vaule_selected")
        return imageView
    }()
    
    func setupUI(){
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightImageView)
        showNormal()
    }
    
    func setupConstraints(){
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    func showNormal(){
        titleLabel.textColor = BlackColor
        rightImageView.isHidden = true
        
    }
    
    func showSelected(){
        titleLabel.textColor = Color9A1E2E
        rightImageView.isHidden = false
        
    }
    
    override func addSubViews() {
        setupUI()
        setupConstraints()
    }
}
