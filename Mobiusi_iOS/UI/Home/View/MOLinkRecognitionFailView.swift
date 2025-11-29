//
//  MOLinkRecognitionFailView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/2.
//

import UIKit

class MOLinkRecognitionFailView: MOView {
	lazy var imageView = {
		let vi = UIImageView()
		vi.image = UIImage(namedNoCache: "icon_recognition_fail")
		return vi
	}()
	
	lazy var tipLabel = {
		let label = UILabel(text: "链接解析取失败", textColor: Color626262!, font: MOPingFangSCMediumFont(12))
		return label
	}()
	
	func setupUI(){
		self.addSubview(imageView)
		self.addSubview(tipLabel)
	}
	
	func setupConstraints(){
		imageView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview()
		}
		
		tipLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(imageView.snp.bottom)
			make.bottom.equalToSuperview()
		}
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
	}
}
