//
//  MOFoodSafetyAnalysisRecordCell.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/28.
//

import UIKit

class MOFoodSafetyAnalysisRecordCell: MOBaseToolRecordCell {

	
	override func addSubViews() {
		super.addSubViews()
		stateView.titleLabel.text = NSLocalizedString("Mobiwusi食品安全分析", comment: "")
		stateView.leftImageView.image = UIImage(namedNoCache: "icon_ai_camera_icon_red")
	}
}
