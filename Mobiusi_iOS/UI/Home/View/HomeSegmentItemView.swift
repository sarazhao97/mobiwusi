//
//  HomeSegmentItemView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/23.
//

import Foundation
class HomeSegmentItemView:MOView {
    
    var didClick:(()->Void)?
     lazy var btn = {
        var btn = MOButton()
		 btn.adjustsImageWhenHighlighted = false
		 btn.setTitle("", titleColor: BlackColor, bgColor: ColorEDEEF5!, font: MOPingFangSCMediumFont(12))
        return btn
    }()
    
    
    lazy var bgView =  {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.top, radius: 14)
        return vi
    }()
    
    lazy var bgView1 =  {
        let vi = MOView()
        return vi
    }()
    lazy var gradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [WhiteColor?.cgColor as Any,ColorEDEEF5?.cgColor as Any]
		gl.startPoint = CGPoint(x: 1, y: 0.3)
        gl.endPoint = CGPoint(x: 1, y: 1)
        gl.locations = [0,1]
		gl.isHidden = true
        return gl
    }()
    func setupUI(){
        self.addSubview(bgView)
        self.addSubview(btn)
        
    }
    
    func setupConstraints(){
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
			make.bottom.equalToSuperview()
//            make.height.equalTo(self.snp.height)
        }
        
        btn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(bgView.snp.top)
            make.right.equalToSuperview()
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
        }
    }
    
	
	func setBtnBGImage(nomalImage:UIImage,selectImage:UIImage)  {
		let capInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		let resizableNormalImage = nomalImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
		let resizableSelectImage = selectImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
		btn.setBackgroundImage(resizableSelectImage, for: UIControl.State.selected)
		btn.setBackgroundImage(resizableNormalImage, for: UIControl.State.normal)
		btn.setBackgroundImage(resizableNormalImage, for: UIControl.State.highlighted)
	}
	
    func addAction(){
        btn.addTarget(self, action: #selector(btnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func btnClick(){
		
        didClick?()
    }
    
    @objc public func showNormalStyle(){
		btn.isSelected = false

    }
    
    @objc public func showSelectedStyle(){
		btn.isSelected = true
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if gradientLayer.frame.size.width != bgView.frame.width || gradientLayer.frame.size.height != bgView.frame.height {
            gradientLayer.frame = bgView.bounds
            
        }
    }
    
    override func addSubViews(inFrame frame: CGRect) {
        setupUI()
        setupConstraints()
        addAction()
    }
    
}
