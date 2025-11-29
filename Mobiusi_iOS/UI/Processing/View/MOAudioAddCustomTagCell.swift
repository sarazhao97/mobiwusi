//
//  MOAudioAddCustomTagCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/22.
//

import Foundation
class MOAudioAddCustomTagCell: UICollectionViewCell {
    
    
    lazy var customContentView = {
        let vi = MOView()
        vi.cornerRadius(QYCornerRadius.all, radius: 6)
        vi.backgroundColor = WhiteColor
        return vi
    }()
    
    lazy var addBtn = {
        let btn = MOButton()
        btn.setTitle("添加", titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCMediumFont(12))
        btn.setImage(UIImage(namedNoCache: "icon_add_tag"))
        return btn
    }()
    
    
    func setupUI(){
        
        contentView.backgroundColor = ClearColor
        contentView.addSubview(customContentView)
        
        customContentView.addSubview(addBtn)
        addBtn.isEnabled = false
        
    }
    
    func setupConstraints(){
        
        customContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().offset(1)
        }
        addBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
    }
    
    func addSubviews() {
        setupUI()
        setupConstraints()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
