//
//  MONewHomeTaskCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/13.
//

import UIKit
@objcMembers
class MONewHomeTaskCell: MOTableViewCell {

	lazy var customView = {
		let vi = MOView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 10)
		return vi
	}()
	lazy var titleLabel = {
		let label = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCBoldFont(14))
		return label
	}()
	
	lazy var itemTypeImageView = {
		let imageView = UIImageView()
		return imageView
	}()
	
	lazy var remainingQuotaLabel = {
		let label = UILabel(text: "", textColor: Color90ABD3!, font: MOPingFangSCMediumFont(10))
		return label
	}()
	
	lazy var tidLabel = {
		let label = UILabel(text: "", textColor: Color626262!, font: MOPingFangSCMediumFont(10))
		return label
	}()
	
	lazy var subTitleLabel = {
		let label = UILabel(text: "", textColor: Color626262!, font: MOPingFangSCMediumFont(12))
		return label
	}()
	
	lazy var unitPriceLabel = {
		let label = UILabel()
		return label
	}()
	
	
	func setupUI(){
		contentView.addSubview(customView)
		customView.addSubview(titleLabel)
		customView.addSubview(itemTypeImageView)
		customView.addSubview(remainingQuotaLabel)
		customView.addSubview(tidLabel)
		customView.addSubview(subTitleLabel)
		customView.addSubview(unitPriceLabel)
		
	}
	
	func setupConstraints(){
		
		customView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(11)
			make.right.equalToSuperview().offset(-11)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview().offset(-10)
		}
		
		titleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(18)
			make.top.equalToSuperview().offset(15)
		}
		
		itemTypeImageView.snp.makeConstraints { make in
			make.left.equalTo(titleLabel.snp.right).offset(5)
			make.right.equalToSuperview().offset(-10)
			make.centerY.equalTo(titleLabel.snp.centerY)
		}
		itemTypeImageView.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		itemTypeImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		
		remainingQuotaLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(18)
			make.top.equalTo(titleLabel.snp.bottom).offset(10)
		}
		
		tidLabel.snp.makeConstraints { make in
			make.left.equalTo(remainingQuotaLabel.snp.right).offset(18)
			make.centerY.equalTo(remainingQuotaLabel.snp.centerY)
		}
		
		subTitleLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(18)
			make.top.equalTo(remainingQuotaLabel.snp.bottom).offset(9)
		}
		
		unitPriceLabel.snp.makeConstraints { make in
			make.left.equalTo(subTitleLabel.snp.right).offset(5)
			make.right.equalToSuperview().offset(-15)
			make.centerY.equalTo(subTitleLabel.snp.centerY)
		}
		
		unitPriceLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
		unitPriceLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)

	}
	
	
	@objc func configHomeCell(model:MOTaskListModel) {
		titleLabel.text = model.title
		let taskTypeImage = model.task_type == 2 ? "icon_reprocessing_project":"icon_collection_project"
		itemTypeImageView.image = UIImage(namedNoCache: taskTypeImage)
		subTitleLabel.text = model.simple_descri
		remainingQuotaLabel.text = String(format: NSLocalizedString("剩%d名额/%d", comment: ""), model.remaining_places,model.person_limit)
		tidLabel.text = String(format: NSLocalizedString("PoID:%@", comment: ""), model.task_no)
		let arrt1 = NSMutableAttributedString.create(with: model.currency_unit ?? "", font: MOPingFangSCHeavyFont(12), textColor: Color9A1E2E!)
		let arrt2 = NSMutableAttributedString.create(with: model.price ?? "", font: MOPingFangSCHeavyFont(20), textColor: Color9A1E2E!)
		let arrt3 = NSMutableAttributedString.create(with: model.unit ?? "", font: MOPingFangSCHeavyFont(12), textColor: Color9A1E2E!)
		arrt1.append(arrt2)
		arrt1.append(arrt3)
		if Float(model.price ?? "") ?? 0  > 0 {
			unitPriceLabel.attributedText = arrt1
		} else {
			unitPriceLabel.attributedText = nil
		}
		
	}
	
	
	override func addSubViews() {
		setupUI()
		setupConstraints()
		
	}

}
