//
//  MOAudioTagCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioTagCell: UICollectionViewCell {
    
	var didClickDelete:(()->Void)?
	
    lazy var titleLabel = {
        let label = UILabel(text: "方言", textColor: BlackColor, font: MOPingFangSCMediumFont(12))
        label.textAlignment = .center
        return label
    }()
    
    lazy var deleteBtn = {
        var btn = MOButton()
        btn.setImage(UIImage(namedNoCache: "icon_tag_delete"))
        btn.setEnlargeEdgeWithTop(5, left: 5, bottom: 5, right: 5)
		btn.contentEdgeInsets = .zero
		btn.imageEdgeInsets = .zero
        return btn
    }()
    
    lazy var customContentView = {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.all, radius: 6)
        return vi
    }()
    

    
    func setupUI(){
        contentView.backgroundColor = ClearColor
        contentView.addSubview(customContentView)
        customContentView.addSubview(titleLabel)
        customContentView.addSubview(deleteBtn)
        showUnselectedStyle()
        
    }
    
    func setupConstraints(){
        customContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().offset(1)
        }
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        deleteBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
			make.top.equalToSuperview().offset(-5)
        }
    }
    
    func showUnselectedStyle(){
        customContentView.cornerRadius(QYCornerRadius.all, radius: 6)
        customContentView.backgroundColor = WhiteColor
        deleteBtn.isHidden = true
        titleLabel.textColor = BlackColor
        
    }
    
    func showSelectedStyle(){
        customContentView.cornerRadius(QYCornerRadius.all, radius: 6, borderWidth: 1, borderColor: Color9A1E2E)
        customContentView.backgroundColor = Color9A1E2E?.withAlphaComponent(0.15)
        deleteBtn.isHidden = true
        titleLabel.textColor = Color9A1E2E
        customContentView.setNeedsLayout()
    }
    
    func showCanDeleteStyle(){
        customContentView.cornerRadius(QYCornerRadius.all, radius: 6, borderWidth: 1, borderColor: Color9A1E2E)
        customContentView.backgroundColor = Color9A1E2E?.withAlphaComponent(0.15)
        deleteBtn.isHidden = false
        titleLabel.textColor = Color9A1E2E
        customContentView.setNeedsLayout()
        
    }
	
	func addActions(){
		deleteBtn.addTarget(self, action: #selector(deleteBtnClick), for: UIControl.Event.touchUpInside)
	}
	
	@objc func deleteBtnClick(){
		
		didClickDelete?()
	}
    
    func addSubviews() {
        setupUI()
        setupConstraints()
		addActions()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
