//
//  MOToChooseVIew.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/28.
//

import Foundation

class MOToChooseVIew: MOView {
    
    
    var didClick:(()->Void)?
    
    var titleTF:UITextField = {
        
        let tf = UITextField(frame: CGRect())
        return tf
        
    }()
    
    var arrowImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(namedNoCache: "icon_black_arrow_r")
        return imageView
    }()
    
    
    func setupUI(){
        
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        self.addGestureRecognizer(tap)
        self.addSubview(titleTF)
        titleTF.isEnabled = false
        self.addSubview(arrowImageView)
    }
    
    func setupConstraints(){
        titleTF.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21.5)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.left.equalTo(titleTF.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        arrowImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        arrowImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    
    init(placeholder: String?) {
        self.titleTF.placeholder = placeholder
        super.init(frame: CGRect())
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapClick(){
        
        didClick?()
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
    }
}
