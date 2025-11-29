//
//  MOUploadImageView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/27.
//

import Foundation
class MOUploadImageView: MOView {
    
    var didClick:(()->Void)?
    var titleLabel:UILabel = {
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(16))
        label.numberOfLines = 0
        return label
    }()
    
    var subTitleLabel:UILabel = {
        let label = UILabel(text: "", textColor: ColorB4B4B4!, font: MOPingFangSCMediumFont(12))
        label.numberOfLines = 0
        return label
    }()
    
    var imageContent:MOView = {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 1, borderColor: ColorCAE2EE)
        return vi
    }()
    
    
    var bgimageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var centerContentView:MOView = {
        
        let vi = MOView()
        return vi
    }()
    
    var centerImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(namedNoCache: "icon_photo_add")
        return imageView
    }()
    
    var centerTitleLabel:UILabel = {
        let label = UILabel(text: NSLocalizedString("点击拍摄/上传", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(12))
        label.textAlignment = .center
        return label
    }()
    
    
    func setupUI(){
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        self.addSubview(imageContent)
        imageContent.addSubview(bgimageView)
        imageContent.addSubview(centerContentView)
        centerContentView.addSubview(centerImageView)
        centerContentView.addSubview(centerTitleLabel)
    }
    
    func setupConstraints(){
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-22)
            
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-22)
            
        }
        
        imageContent.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(194)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        bgimageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        centerContentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        centerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            
        }
        
        centerTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(centerImageView.snp.bottom).offset(13)
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            
            
        }
    }
    
    init(title:String?, subTitle: String?,bgimageName:String,) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.bgimageView.image = UIImage(namedNoCache: bgimageName)
        super.init(frame: CGRect())
    }
    
    func configImage(selectedImage:UIImage) {
        centerContentView.isHidden = true
        bgimageView.image = nil
        bgimageView.image = selectedImage
    }
    
    func addActions(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageContentCilck))
        imageContent.addGestureRecognizer(tap)
    }
    
    @objc func imageContentCilck(){
        
        didClick?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
        addActions()
    }
    
}
