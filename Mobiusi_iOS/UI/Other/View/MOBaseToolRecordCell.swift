//
//  MOBaseToolRecordCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit

class MOBaseToolRecordCell: MOBaseScheduleNoBottomCell {

	var didClickPreview:(()->Void)?
	lazy var attachmentFilesView = {
		let vi = MOView()
		return vi
	}()
	
	lazy var lineView = {
		let vi = MOView()
		vi.backgroundColor = ColorF2F2F2
		return vi
	}()
	
	lazy var stateView = {
		let vi = MODataSummarizeStateView()
		vi.cornerRadius(QYCornerRadius.all, radius: 6)
		vi.backgroundColor = ColorF6F7FA
		vi.titleLabel.text = NSLocalizedString("出国翻译官", comment: "")
		vi.leftImageView.image = UIImage(namedNoCache: "icon_translate_ZH_A")
		return vi
	}()
	
	func setupUI(){
		
		self.dataContentView.categoryDataView.addSubview(attachmentFilesView)
		self.dataContentView.categoryDataView.addSubview(lineView)
		self.dataContentView.categoryDataView.addSubview(stateView)
		stateView.showInProcessStyle()
	}
	
	func setupConstraints(){
		
		attachmentFilesView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalToSuperview().offset(9)
		}
		
		lineView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(attachmentFilesView.snp.bottom).offset(10)
			make.height.equalTo(1)
		}
		
		stateView.snp.makeConstraints { make in
			make.left.equalToSuperview().offset(13)
			make.right.equalToSuperview().offset(-10)
			make.top.equalTo(lineView.snp.bottom).offset(10)
			make.height.equalTo(30)
			make.bottom.equalToSuperview().offset(-10)
		}
	}
	
	
	func configCellWithModel(model:MOTranslateTextRecordItemModel) {
		timeLabel.text = model.create_time
		stateView.stateLabel.text = model.status_text
		stateView.stateLabel.textColor = model.status == 1 ? Color34C759:ColorFC9E09
		for vi in attachmentFilesView.subviews {
			vi.removeFromSuperview()
		}
		
		let imageView = UIImageView()
		imageView.isUserInteractionEnabled = true
		let tap = UITapGestureRecognizer(target: self, action: #selector(previewClick))
		imageView.addGestureRecognizer(tap)
		imageView.contentMode = .scaleAspectFill
		imageView.backgroundColor = ColorEDEEF5
		imageView.cornerRadius(QYCornerRadius.all, radius: 10)
		attachmentFilesView.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.height.equalTo(imageView.snp.width)
			make.width.equalToSuperview().multipliedBy(1.0/3.0).offset(-20.0/3.0)
			make.left.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
		
		if let imageUrl = URL(string: model.result_url ?? "") {
			imageView.sd_setImage(with: imageUrl)
		}
		
		
	}
	
	@objc func previewClick(){
		// 预览点击事件由外部处理
        didClickPreview?()
	}
	
	override func addSubViews() {
		super.addSubViews()
		setupUI()
		setupConstraints()
	}
}
