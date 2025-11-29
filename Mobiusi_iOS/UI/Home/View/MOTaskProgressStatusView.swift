//
//  MOTaskTagView.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/13.
//

import UIKit

class MOTaskProgressStatusView: MOView {

	
	lazy var leftcontentView = {
		let vi = MOView()
		vi.cornerRadius(QYCornerRadius.all, radius: 4)
		return vi
	}()
	
	lazy var leftLabel = {
		let label = UILabel(text: "", textColor: WhiteColor!, font: MOPingFangSCMediumFont(10))
		label.cornerRadius(QYCornerRadius.all, radius: 4)
		return label
	}()
	
	lazy var rightLabel = {
		let label = UILabel(text: "", textColor: WhiteColor!, font: MOPingFangSCMediumFont(10))
		label.backgroundColor = ClearColor
		return label
	}()
	
	func setupUI(){
		self.addSubview(leftcontentView)
		leftcontentView.addSubview(leftLabel)
		self.addSubview(rightLabel)
	}
	
	func setupConstraints(){
		
		leftcontentView.snp.makeConstraints { make in
			make.left.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			
		}
		leftLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(4)
			make.right.equalToSuperview().offset(-4)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			
		}
		
		rightLabel.snp.makeConstraints { make in
			make.left.equalTo(leftcontentView.snp.right).offset(4)
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.right.equalToSuperview().offset(-3)
			
		}
	}
	
	func showTestDataStyle(){
		
		self.leftLabel.text = NSLocalizedString("测试数据", comment: "")
		self.leftcontentView.backgroundColor = ColorFC9E09
		self.rightLabel.textColor = ColorFC9E09
		self.backgroundColor = ColorFC9E09?.withAlphaComponent(0.15)
	}
	
	func showOfficialDataStyle(){
		
		self.leftLabel.text = NSLocalizedString("正式数据", comment: "")
		self.leftcontentView.backgroundColor = Color9A1E2E
		self.rightLabel.textColor = Color9A1E2E
		self.backgroundColor = Color9A1E2E?.withAlphaComponent(0.15)
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		
		setupUI()
		setupConstraints()
	}
	
}
