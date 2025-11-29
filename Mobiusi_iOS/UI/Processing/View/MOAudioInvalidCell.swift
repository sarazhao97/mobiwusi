//
//  MOAudioInvalidCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOAudioInvalidCell:MOTableViewCell {
    
	
	var switchValueChanged:((_ isOn:Bool)->Void)?
	
    lazy var cunstomContentView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var titleLabel = {
        let label = UILabel(text: NSLocalizedString("音频是否有效", comment: ""), textColor: BlackColor, font: MOPingFangSCMediumFont(15))
        label.textAlignment = .right
        return label
    }()
    
    lazy var rightswitch = {
        let sw = UISwitch()
		sw.onTintColor = Color9A1E2E
        return sw
    }()
    
    func setupUI(){
        contentView.addSubview(cunstomContentView)
        cunstomContentView.addSubview(titleLabel)
        cunstomContentView.addSubview(rightswitch)
    }
    
    func setupConstraints(){
        cunstomContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.centerY.equalToSuperview()
            
        }
        rightswitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
    }
	
	func addActions(){
		rightswitch.addTarget(self, action: #selector(rightswitchValueChange), for: UIControl.Event.valueChanged)
	}
	
	@objc func rightswitchValueChange() {
		switchValueChanged?(rightswitch.isOn)
	}
    
    override func addSubViews() {
        
        setupUI()
        setupConstraints()
		addActions()
    }
}
