//
//  MOPorcessingDataPSHView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOPorcessingDataPSHView:UITableViewHeaderFooterView {
    
    var addBtnDidClick:(()->Void)?
    
    lazy var cunstomContentView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var addBtn = {
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("添加片段", comment: ""), titleColor: BlackColor, bgColor: ClearColor, font: MOPingFangSCHeavyFont(15))
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        btn.setImage(UIImage(namedNoCache: "icon_cropping"))
        return btn
    }()
    
    func setupUI(){
        contentView.addSubview(cunstomContentView)
        cunstomContentView.addSubview(addBtn)

    }
    
    func setupConstraints(){
        cunstomContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        addBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    func addSubviews() {
        setupUI()
        setupConstraints()
        addAction()
    }
    
    func addAction(){
        addBtn.addTarget(self, action: #selector(addBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func addBtnClick(){
        addBtnDidClick?()
    }
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
