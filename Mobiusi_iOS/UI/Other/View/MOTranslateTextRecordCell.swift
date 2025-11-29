//
//  MOTranslateTextRecordCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

@objcMembers
class MOTranslateTextRecordCell: MOBaseToolRecordCell {
	override func addSubViews() {
		super.addSubViews()
		stateView.titleLabel.text = NSLocalizedString("出国翻译官", comment: "")
		stateView.leftImageView.image = UIImage(namedNoCache: "icon_translate_ZH_A")
	}
	 @objc override func previewClick() {
        // 预览点击事件由外部处理
        didClickPreview?()
    }
}
