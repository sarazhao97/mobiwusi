//
//  MOPromptOperationView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOPromptOperationView:MOView {
    
    lazy var textLabel = {
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCMediumFont(14))
        return label
    }()
    lazy var warningImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_attention")
        return imageView
    }()
    
    lazy var moreImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(namedNoCache: "icon_black_arrow_r")
        return imageView
    }()
    
    func setupUI(){
        self.addSubview(textLabel)
        self.addSubview(warningImageView)
        self.addSubview(moreImageView)
    }
    
    func setupConstraints(){
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        
        warningImageView.snp.makeConstraints { make in
            make.left.equalTo(textLabel.snp.right).offset(5)
            make.centerY.equalTo(textLabel.snp.centerY)
        }
        moreImageView.snp.makeConstraints { make in
            make.left.equalTo(warningImageView.snp.right)
            make.centerY.equalTo(textLabel.snp.centerY)
            make.right.equalToSuperview()
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
    }
}
