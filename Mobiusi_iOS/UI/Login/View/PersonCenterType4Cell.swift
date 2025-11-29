//
//  PersonCenterType4Cell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/31.
//

import Foundation

class PersonCenterType4Cell: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding {
    var didSelectedCell: ((UITableViewCell) -> Void)?
    var cellHeight: CGFloat = 50
    
    let centerTitleLabel:UILabel = {
        let centerTitleLabel:UILabel = UILabel.init(text: "", textColor: ColorA2002D!, font: MOPingFangSCHeavyFont(14))
        centerTitleLabel.backgroundColor = WhiteColor
        centerTitleLabel.textAlignment = NSTextAlignment.center
        return centerTitleLabel
    }()
    override func addSubViews() {
        self.contentView.addSubview(centerTitleLabel)
        centerTitleLabel.cornerRadius(QYCornerRadius.all, radius: 15)
        centerTitleLabel.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }
    
}
