//
//  MOBaseScheduleNoBottomCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

class MOBaseScheduleNoBottomCell: MOTableViewCell {

	var timeLabel = {
		let lable = UILabel(text: "", textColor: BlackColor, font: MOPingFangSCMediumFont(13))
		return lable
	}()
	
	var scheduleCircleView = {
		let vi = MOView()
		vi.backgroundColor = ClearColor
		vi.cornerRadius(QYCornerRadius.all, radius: 4, borderWidth: 2, borderColor: MainSelectColor)
		return vi
	}()
	
	var scheduleVerticalTopView = {
		let vi = MOView()
		vi.backgroundColor = ColorD9DAE3
		return vi
	}()
	var scheduleVerticalBottomView = {
		let vi = MOView()
		vi.backgroundColor = ColorD9DAE3
		return vi
	}()
	
	var dataContentView = {
		let vi = MOBaseDataContentNoBottomView()
		vi.backgroundColor = WhiteColor
		vi.cornerRadius(QYCornerRadius.all, radius: 10)
		return vi
	}()
	
	func setupUIBase(){
		contentView.backgroundColor = ClearColor
		contentView.addSubview(scheduleCircleView)
		contentView.addSubview(timeLabel)
		contentView.addSubview(scheduleVerticalTopView)
		contentView.addSubview(scheduleVerticalBottomView)
		contentView.addSubview(dataContentView)
		
	}
	
	func setupConstraintsBase(){
		
		
		scheduleCircleView.snp.makeConstraints { make in
			make.left.equalTo(12)
			make.width.height.equalTo(8)
			make.centerY.equalTo(timeLabel.snp.centerY)
		}

		timeLabel.snp.makeConstraints { make in
			make.left.equalTo(contentView.snp.left).offset(30)
			make.right.equalTo(contentView.snp.right).offset(-8)
			make.top.equalTo(contentView.snp.top).offset(16)
		}
		
		scheduleVerticalTopView.snp.makeConstraints { make in
			make.centerX.equalTo(scheduleCircleView.snp.centerX)
			make.top.equalTo(contentView.snp.top)
			make.bottom.equalTo(scheduleCircleView.snp.top)
			make.width.equalTo(2)
		}
		
		scheduleVerticalBottomView.snp.makeConstraints { make in
			make.centerX.equalTo(scheduleCircleView.snp.centerX)
			make.top.equalTo(scheduleCircleView.snp.bottom)
			make.bottom.equalTo(contentView.snp.bottom)
			make.width.equalTo(2)
		}
		
		dataContentView.snp.makeConstraints { make in
			make.left.equalTo(contentView.snp.left).offset(34)
			make.top.equalTo(timeLabel.snp.bottom).offset(2)
			make.right.equalTo(contentView.snp.right).offset(-8)
			make.bottom.equalTo(contentView.snp.bottom).offset(1)
		}
	}
	
	override func addSubViews() {
		setupUIBase()
		setupConstraintsBase()
	}
	
	
}


class MOBaseDataContentNoBottomView:MOView {
	var categoryDataView = {
		let vi = MOView()
		return vi
	}()
	
	func setupUI(){
		self.addSubview(categoryDataView)
	}
	
	func setupConstraints(){
		categoryDataView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	override func addSubViews(inFrame frame: CGRect) {
		setupUI()
		setupConstraints()
		
	}
}
