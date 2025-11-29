//
//  MOAudioAttributeCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/21.
//

import Foundation
class MOAudioAttributeCell:MOTableViewCell {
    
    lazy var cunstomContentView = {
        let vi = MOView()
        vi.backgroundColor = WhiteColor
        vi.cornerRadius(QYCornerRadius.all, radius: 12)
        return vi
    }()
    
    lazy var titleLabel = {
        let label = UILabel(text: "音频属性", textColor: BlackColor, font: MOPingFangSCMediumFont(15))
        label.textAlignment = .right
        return label
    }()
    
    lazy var subTitleLabel = {
        let label = UILabel(text: "准确填写音频属性，有机会获得更多加工数据奖励", textColor: Color626262!, font: MOPingFangSCMediumFont(12))
        label.textAlignment = .right
        return label
    }()
    
    lazy var waningView = {
        let vi = MOPromptOperationView()
        return vi
    }()
    
    lazy var completeView = {
        let vi = MOOperationCompleteView()
		vi.textLabel.textColor = Color34C759
		return vi
    }()
    
    func setupUI(){
        contentView.addSubview(cunstomContentView)
        cunstomContentView.addSubview(titleLabel)
        cunstomContentView.addSubview(waningView)
        cunstomContentView.addSubview(completeView)
        cunstomContentView.addSubview(subTitleLabel)
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
            make.top.equalToSuperview().offset(13)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(23)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        
        waningView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-10)
        }
        
        completeView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.right.equalToSuperview().offset(-10)
        }
    }
	
	func configCellAttibueValue(model:MOAudioClipSegmentCustomModel) {
		
		if let audio_property_original = model.audio_property_original {
			let totalCount = audio_property_original.count
			var needToDoCount = 0
			for item in audio_property_original {
				if !item.isSelected {
					needToDoCount += 1
				}
			}
			
			if needToDoCount == 0 {
				waningView.isHidden = true
				completeView.isHidden = false
				completeView.textLabel.text = String(format: "已填写%d项", totalCount)
			}else {
				
				waningView.isHidden = false
				completeView.isHidden = true
				waningView.textLabel.text = String(format: NSLocalizedString("%d项待填写", comment: ""), needToDoCount)
			}
			
		}
		
	}
	
	func configCellTagsValue(model:MOAudioClipSegmentModel) {
		
		waningView.isHidden = false
		completeView.isHidden = true
		waningView.textLabel.text = NSLocalizedString("添加标签", comment: "")
		if let tags = model.tags {
			let totalCount = tags.count
			if totalCount > 0 {
				waningView.isHidden = true
				completeView.isHidden = false
				completeView.textLabel.text = String(format: NSLocalizedString("已添加%d个标签", comment: ""), totalCount)
			}else {
				waningView.isHidden = false
				completeView.isHidden = true
				waningView.textLabel.text = NSLocalizedString("添加标签", comment: "")
			}
			
		}
		
	}
    
    override func addSubViews() {
        
        setupUI()
        setupConstraints()
    }
}
