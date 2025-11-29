//
//  MOOperationCompleteView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOOperationCompleteView:MOView {
    
    lazy var textLabel = {
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCMediumFont(14))
        return label
    }()

    
    lazy var moreImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_black_arrow_r")
        return imageView
    }()
    
    func setupUI(){
        self.addSubview(textLabel)
        self.addSubview(moreImageView)
    }
    
    func setupConstraints(){
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        
        moreImageView.snp.makeConstraints { make in
            make.left.equalTo(textLabel.snp.right)
            make.centerY.equalTo(textLabel.snp.centerY)
            make.right.equalToSuperview()
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
    }
}
