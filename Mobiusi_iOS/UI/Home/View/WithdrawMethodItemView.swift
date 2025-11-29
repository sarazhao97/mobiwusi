//
//  WithdrawMethodItemView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/5.
//

import Foundation

class WithdrawMethodItemView: MOView {
    public lazy var iconImageView:UIImageView = {
        let imageView:UIImageView = UIImageView();
        return imageView
    }()
    
    public lazy var titleLable:UILabel = {
        
        let lable = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(14))
        return lable
    }()
    
    
    public lazy var tagContentView:MOView = {
        
        let vi = MOView()
        vi.backgroundColor = ColorFF9A07 as? UIColor ?? UIColor.orange // 橙红色背景
        vi.cornerRadius(QYCornerRadius.all, radius: 2) // 增加圆角半径
        return vi
    }()
    
    public lazy var tagLable:UILabel = {
        
        let lable = UILabel(text: NSLocalizedString("推荐", comment: ""), textColor: WhiteColor!, font: MOPingFangSCMediumFont(10))
        lable.textAlignment = NSTextAlignment.center
        lable.minimumScaleFactor = 0.3
        lable.adjustsFontSizeToFitWidth = true
        lable.cornerRadius(QYCornerRadius.all, radius: 4)
        return lable
    }()
    
    // 勾选框图片视图
    public lazy var checkBoxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_withdrawal_normal")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public var clickEvent:(()->Void)?
    
    override func addSubViews(inFrame frame: CGRect) {
         
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(26)
            make.height.equalTo(26)
          
        }
        iconImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        iconImageView.contentMode = .scaleAspectFit
        
        self.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        titleLable.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        self.addSubview(tagContentView)
        tagContentView.snp.makeConstraints { make in
            make.left.equalTo(titleLable.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-5)
            make.height.equalTo(18) // 增加高度以容纳上下内边距
        }
        
        tagContentView.addSubview(tagLable)
        tagLable.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5) // 左右内边距
            make.right.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(4) // 上内边距
            make.bottom.equalToSuperview().offset(-4) // 下内边距
        }
        
        // 添加勾选框图片
        self.addSubview(checkBoxImageView)
        checkBoxImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20) // 调整勾选框尺寸
            make.height.equalTo(20) // 调整勾选框尺寸
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapClick))
        self.addGestureRecognizer(tap)
    }
    
    @objc func tapClick(){
        
        guard let clickEvent = clickEvent else {
            return
        }

        clickEvent()
    }
    
    func normalSateUI() {
        // 未选中状态：保持默认样式，不改变边框和背景色
        titleLable.textColor = BlackColor
        self.backgroundColor = WhiteColor
        self.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 0, borderColor: UIColor.clear)
        
        // 勾选框：显示未选中图片
        checkBoxImageView.image = UIImage(named: "icon_withdrawal_normal")
        
        self.setNeedsLayout()
    }
    
    func selectedSateUI() {
        // 选中状态：保持默认样式，不改变边框和背景色
        titleLable.textColor = BlackColor
        self.backgroundColor = WhiteColor
        self.cornerRadius(QYCornerRadius.all, radius: 10, borderWidth: 0, borderColor: UIColor.clear)
        
        // 勾选框：显示选中图片
        checkBoxImageView.image = UIImage(named: "icon_withdrawal_select")
        
        self.setNeedsLayout()
    }
}
