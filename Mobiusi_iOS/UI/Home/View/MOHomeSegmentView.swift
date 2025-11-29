//
//  MOHomeSegmentView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/23.
//

import Foundation
@objcMembers
class MOHomeSegmentView: MOView {
    
    var didSelectedIndex:((_ index:Int)->Void)?
    var leftItem = {
        let item = HomeSegmentItemView()
        item.btn.setTitle("", titleColor: BlackColor, bgColor: ColorEDEEF5!, font: MOPingFangSCMediumFont(12))
		item.setBtnBGImage(nomalImage: UIImage(namedNoCache: "icon_summarize_unselect_left"), selectImage: UIImage(namedNoCache: "icon_summarize_select_left"))
        return item
    }()
	
	var leftBGImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_summarize_select_left")
		return imageView
	}()
	
	var rightBGImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(namedNoCache: "icon_summarize_unselect_right")
		return imageView
	}()
    
    var rightItem = {
        let item = HomeSegmentItemView()
        item.btn.setTitle(NSLocalizedString("",comment: ""), titleColor: BlackColor, bgColor: ColorEDEEF5!, font: MOPingFangSCMediumFont(12))
		item.setBtnBGImage(nomalImage: UIImage(namedNoCache: "icon_summarize_unselect_right"), selectImage: UIImage(namedNoCache: "icon_summarize_select_right"))
        return item
    }()
    
    func setupUI(){
        self.addSubview(leftItem)
		
        leftItem.didClick = {[weak self] in
            guard let self  else {return}
            self.leftItem.showSelectedStyle()
            self.rightItem.showNormalStyle()
            didSelectedIndex?(0)
        }
        self.addSubview(rightItem)
        rightItem.didClick = {[weak self] in
            guard let self else {return}
            self.leftItem.showNormalStyle()
            self.rightItem.showSelectedStyle()
            didSelectedIndex?(1)
        }
		self.bringSubviewToFront(leftItem)
		leftItem.showSelectedStyle()
    }
    
    func setupConstraints(){
        
        leftItem.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            make.right.equalTo(self.snp.centerX)
        }
        rightItem.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX)
			make.top.equalToSuperview().offset(10)
			make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    
    override func addSubViews(inFrame frame: CGRect) {
        
        setupUI()
        setupConstraints()
    }
}
