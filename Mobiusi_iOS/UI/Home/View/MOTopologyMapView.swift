//
//  MOTopologyMapView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/30.
//

import UIKit

class MOTopologyMapView: MOView {
    
    var didClickRoate: (() -> Void)?
	var didClickRefresh: (() -> Void)?
	lazy var titleLable: UILabel = {
        let label = UILabel(text: NSLocalizedString("导图", comment: ""), textColor: BlackColor, font: MOPingFangSCHeavyFont(15))
        return label
    }()
    
	lazy var contentView: MOTopologyMapScrollView = {
        let vi = MOTopologyMapScrollView()
        return vi
    }()
	
	lazy var refreshBtn: MOButton = {
		let btn = MOButton()
		btn.setImage(UIImage(namedNoCache: "icon_mind_refresh"))
		btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
		btn.addTarget(self, action: #selector(refreshBtnClick), for: .touchUpInside)
		return btn
	}()
    
	lazy var rotateBtn: MOButton = {
        let btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_interface_orientation_rotate"))
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(rotateBtnClick), for: .touchUpInside)
        return btn
    }()
    
    override func addSubViews(inFrame frame: CGRect) {
        super.addSubViews(inFrame: frame)
        
        addSubview(titleLable)
		addSubview(refreshBtn)
        addSubview(rotateBtn)
        addSubview(contentView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalToSuperview().offset(10)
        }
		
		
        
		contentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLable.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        rotateBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(contentView.snp.top).offset(-10)
        }
		
		refreshBtn.snp.makeConstraints { make in
			make.right.equalTo(rotateBtn.snp.left).offset(-10)
			make.centerY.equalTo(titleLable.snp.centerY)
		}
    }
    
    @objc private func rotateBtnClick() {
        didClickRoate?()
    }
	
	@objc private func refreshBtnClick() {
		didClickRefresh?()
	}
}
