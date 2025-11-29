//
//  MOCountryCodeCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/2.
//

import Foundation

class MOCountryCodeCell: MOTableViewCell {
    public lazy var leftLabel = {
        let label = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(14))
        return label
    }()
    
    public lazy var rightLabel = {
        let label = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCHeavyFont(14))
        return label
    }()
    
    override func addSubViews() {
        contentView.backgroundColor = WhiteColor
        contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(29)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).offset(-29)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    }
}
