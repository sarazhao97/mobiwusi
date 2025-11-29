//
//  MOFoodSafeRecordCell.swift
//  Mobiusi_iOS
//
//  Created by MY on 2025/11/17.
//

import UIKit

@objcMembers
class MOFoodSafeRecordCell: MOBaseToolRecordCell {
    override func addSubViews() {
        super.addSubViews()
        stateView.titleLabel.text = NSLocalizedString("食品安全员", comment: "")
        stateView.leftImageView.image = UIImage(named: "icon_foodanalysis_logo")
    }
    
    func configCellWithModel(model: MOFoodSafeRecordItemModel) {
        timeLabel.text = model.create_time
        stateView.stateLabel.text = model.status_zh
        stateView.stateLabel.textColor = model.status == 1 ? Color34C759 : ColorFC9E09
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
        
        if let imageUrl = URL(string: model.image_url ?? "") {
            imageView.sd_setImage(with: imageUrl)
        }
    }
    
    @objc override func previewClick() {
        // 预览点击事件由外部处理
        didClickPreview?()
    }
}
