//
//  MODataPartnerTaskCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/4/24.
//

import Foundation
class MODataPartnerTaskCell: MOTableViewCell,@preconcurrency PersonCenterTypeCellProviding {
    var cellHeight: CGFloat = 76
    
    var didSelectedCell: ((UITableViewCell) -> Void)?
    var didCickDoBtn:(()->Void)?
    
    var letImageView:UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var taskLabel:UILabel = {
        
        let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(15))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    var tagLabel:UILabel = {
        
        let label = UILabel(text: "", textColor: ColorAFAFAF!, font: MOPingFangSCMediumFont(12))
        label.backgroundColor = ColorEFF7FA
        label.cornerRadius(QYCornerRadius.all, radius: 4)
        label.textAlignment = .left
        return label
    }()
    
    var pointsValueLabel:UILabel = {
        
        let label = UILabel()
        return label
    }()
    
    var toCompleteBtn:MOButton = {
        
        let btn = MOButton()
        btn.setTitle(NSLocalizedString("去完成", comment: ""), titleColor: WhiteColor!, bgColor: MainSelectColor!, font: MOPingFangSCHeavyFont(12))
        btn.fixAlignmentBUG()
        btn.cornerRadius(QYCornerRadius.all, radius: 20)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        return btn
    }()
    
    func setupUI(){
        contentView.backgroundColor = WhiteColor
        contentView.addSubview(letImageView)
        contentView.addSubview(taskLabel)
        tagLabel.isHidden = true
        contentView.addSubview(tagLabel)
        contentView.addSubview(pointsValueLabel)
        contentView.addSubview(toCompleteBtn)
    }
    
    func setupConstraints(){
        
        letImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(17)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        
        taskLabel.snp.makeConstraints { make in
            make.left.equalTo(letImageView.snp.right).offset(9)
            make.top.equalTo(letImageView.snp.top)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.left.equalTo(taskLabel.snp.left)
            make.bottom.equalTo(letImageView.snp.bottom)
//            make.width.equalTo(38)
            make.height.equalTo(18)
        }
        tagLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        pointsValueLabel.snp.makeConstraints { make in
//            make.left.equalTo(tagLabel.snp.right).offset(8)
            make.left.equalTo(taskLabel.snp.left)
            make.centerY.equalTo(tagLabel.snp.centerY)
        }
        
        toCompleteBtn.snp.makeConstraints { make in
            make.left.equalTo(taskLabel.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
//            make.width.equalTo(72)
            make.height.equalTo(31)
        }
        toCompleteBtn.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
    }
    
    func configCell(imageName:String?,taskTitle:String?,tagName:String?,pointsFormatValue:String?){
        letImageView.image = UIImage(namedNoCache: imageName ?? "")
        taskLabel.text = taskTitle
        tagLabel.text = tagName
        let attrS1 =  NSMutableAttributedString.create(with: "Mobi分", font: MOPingFangSCMediumFont(12), textColor: ColorAFAFAF!)
        let attrS2 =  NSMutableAttributedString.create(with: pointsFormatValue ?? "", font: MOPingFangSCHeavyFont(12), textColor: MainSelectColor!)
        attrS1.append(attrS2)
        pointsValueLabel.attributedText = attrS1
    }
    
    func configCell(taskModel:MOLevelTaskDataModel){
        letImageView.sd_setImage(with: URL(string: taskModel.icon ?? ""))
        taskLabel.text = taskModel.title
        tagLabel.text = "  \(taskModel.key ?? "")  "
        let attrS1 =  NSMutableAttributedString.create(with: NSLocalizedString("Mobi分", comment: ""), font: MOPingFangSCMediumFont(12), textColor: ColorAFAFAF!)
        let attrS2 =  NSMutableAttributedString.create(with: String(format: " +%d", taskModel.point), font: MOPingFangSCHeavyFont(12), textColor: MainSelectColor!)
        attrS1.append(attrS2)
        
        pointsValueLabel.attributedText = attrS1
        let stateTitle = [0:NSLocalizedString("去完成", comment: ""),1:NSLocalizedString("审核中", comment: ""),2:NSLocalizedString("已通过", comment: ""),3:NSLocalizedString("未通过", comment: "")]
//        let stateBgColor = [0:MainSelectColor,1:ColorEDEEF5,2:ColorEDEEF5,3:MainSelectColor]
        let stateBgColor = [0:MainSelectColor,1:MainSelectColor,2:MainSelectColor,3:MainSelectColor]
//        let stateTitleColor = [0:WhiteColor,1:Color9B9B9B,2:Color9B9B9B,3:WhiteColor]
        let stateTitleColor = [0:WhiteColor,1:WhiteColor,2:WhiteColor,3:WhiteColor]
        let stateEnable = [0:true,1:false,2:false,3:true]
        let titleColor:UIColor = (stateTitleColor[taskModel.status] ?? WhiteColor!)!
        let bgColor:UIColor = (stateBgColor[taskModel.status] ?? MainSelectColor!)!
        let title:String = stateTitle[taskModel.status] ?? ""
        toCompleteBtn.setTitle(title, titleColor: titleColor, bgColor: bgColor, font: MOPingFangSCHeavyFont(12))
        toCompleteBtn.isEnabled = stateEnable[taskModel.status] ?? true
        
    }
    
    
    func addActions(){
        toCompleteBtn.addTarget(self, action: #selector(toCompleteBtnClick), for: UIControl.Event.touchUpInside)
    }
    
    @objc func toCompleteBtnClick(){
        
        didCickDoBtn?()
    }
    override func addSubViews() {
        setupUI()
        setupConstraints()
        addActions()
    }
}
