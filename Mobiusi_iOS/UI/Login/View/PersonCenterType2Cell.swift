//
//  PersonCenterType2Cell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/31.
//

import Foundation
class PersonCenterType2Cell: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding {
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
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // 使视图成为第一响应者
            rightLabel.becomeFirstResponder()
            let menuController = UIMenuController.shared
            let copyMenuItem = UIMenuItem(title: NSLocalizedString("复制", comment: ""), action: #selector(copyText))
            menuController.menuItems = [copyMenuItem]
            menuController.showMenu(from: self, rect: rightLabel.frame)
        }
    }
    
    @objc func copyText() {
        if let text = rightLabel.text {
            UIPasteboard.general.string = text
        }
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.flat)
        SVProgressHUD.setInfoImage(UIImage().withRenderingMode(.alwaysTemplate))
        SVProgressHUD.setImageViewSize(CGSizeZero)
        SVProgressHUD.dismiss(withDelay: 1.5)
        SVProgressHUD.showInfo(withStatus: NSLocalizedString("已复制", comment: ""))
        
    }
    
    
    
    override func addSubViews() {
        
        self.contentView.addSubview(leftLabel)
        self.contentView.backgroundColor = WhiteColor
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.left).offset(32)
            make.centerY.equalTo(self.contentView.snp.centerY)
            
        }
        leftLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        self.contentView.addSubview(rightLabel)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        rightLabel.addGestureRecognizer(longPressGesture)
        rightLabel.isUserInteractionEnabled = true
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(self.contentView.snp.right).offset(-25)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.left.equalTo(leftLabel.snp.right).offset(10)
            
        }
    }
}


extension UILabel {
    override open var canBecomeFirstResponder: Bool {
        return true
    }
}
