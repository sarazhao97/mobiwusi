//
//  MOAIGenerateRecordCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit

class MOAICameraGenerateRecordCell: MOBaseToolRecordCell {

	
	func configCellWithModel(model:MOGhibliHistoryModel) {
		timeLabel.text = model.create_time
		stateView.stateLabel.text = model.status_zh
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
		
		if let imageUrl = URL(string: model.path_url ?? "") {
			imageView.sd_setImage(with: imageUrl)
		}
		
		
	}
	
	override func addSubViews() {
		super.addSubViews()
		stateView.titleLabel.text = NSLocalizedString("多变摄影师", comment: "")
		stateView.leftImageView.image = UIImage(namedNoCache: "icon_ai_camera_icon_red")
	}
	 @objc override func previewClick() {
        // 预览点击事件由外部处理
        didClickPreview?()
    }
}
