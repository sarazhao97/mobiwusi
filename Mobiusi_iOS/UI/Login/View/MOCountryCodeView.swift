//
//  MOCountryCodeView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

import Foundation
@objcMembers class MOCountryCodeView: MOView {
    public lazy var codeLable: UILabel = {
        
        let lable = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(17))
        return lable
    }()
    
    public lazy var didClick:(()->Void)? = nil;
    
    public lazy var subscriptImageView: UIImageView = {
        
        let imageView = UIImageView(image: UIImage.init(namedNoCache: "Icon_subscript"))
        return imageView
    }()
    
    

    
    override func addSubViews(inFrame frame: CGRect) {
        
        self.addSubview(codeLable)
        codeLable.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left);
            make.centerY.equalTo(self.snp.centerY);
        }
        self.addSubview(subscriptImageView)
        subscriptImageView.snp.makeConstraints { make in
            make.left.equalTo(codeLable.snp.right).offset(6)
            make.right.equalTo(self.snp.right)
            make.centerY.equalTo(self.snp.centerY);
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapEvent))
        self.addGestureRecognizer(tap)
        
    }
    
    @objc func tapEvent(){
        
        if (didClick != nil) {
            didClick!()
        }
    }
}
