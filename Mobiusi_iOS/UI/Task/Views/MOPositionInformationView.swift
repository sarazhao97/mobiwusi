//
//  MOPositionInformationView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/8.
//

import Foundation
class MOPositionInformationView: MOView {
    
    var locateImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_locate")
        return imageView
    }()
    
    var locateNameLabel:UILabel = {
        let label = UILabel(text: NSLocalizedString("不显示位置", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(13))
        return label
    }()
    
    func setupUI(){
        self.addSubview(locateImageView)
        self.addSubview(locateNameLabel)
    }
    
    func setupConstraints(){
        locateImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(19)
            make.centerY.equalToSuperview()
            
        }
        locateImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        locateNameLabel.snp.makeConstraints { make in
            make.left.equalTo(locateImageView.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(4)
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
    }
}
