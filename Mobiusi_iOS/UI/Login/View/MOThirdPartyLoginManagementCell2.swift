//
//  MOThirdPartyLoginManagementCell2.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/9.
//

import Foundation
import Foundation
class MOThirdPartyLoginManagementCell2: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding {
    var didSelectedCell: ((UITableViewCell) -> Void)?
    public var cellHeight:CGFloat = 60
    
    public let leftLabel:UILabel = {
        let label = UILabel.init(text: "", textColor: BlackColor, font:MOPingFangSCFont(15.0))
        return label
    }()
    
    public let rightLabel:UILabel = {
        let label = UILabel.init(text: "", textColor: BlackColor, font: MOPingFangSCFont(14.0))
        label.textAlignment = NSTextAlignment.right;
        return label
    }()
    
    public let rightImage:UIImageView = {
        let image:UIImageView = UIImageView.init(image: UIImage.init(namedNoCache: "icon_black_arrow_r.png"))
        return image
    }()
    
    
    
    override func addSubViews() {
        
        self.contentView.backgroundColor = WhiteColor
        
        self.contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalTo(self.contentView.snp.centerY)
            
        }
        
        self.contentView.addSubview(rightImage)
        rightImage.snp.makeConstraints { make in
            make.right.equalTo(self.contentView.snp.right).offset(-25)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        rightImage.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        rightImage.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        
        self.contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(rightImage.snp.left).offset(-5)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.left.equalTo(leftLabel.snp.right).offset(10)
        }
        
        
    }
}
