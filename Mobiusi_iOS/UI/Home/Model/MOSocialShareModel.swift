//
//  MOSocialShareModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit
@objcMembers
class MOSocialShareModel: MOModel {
	var imageName:String?
	var title:String?
	var identification:String?
	init(imageName: String? = nil, title: String? = nil, identification: String? = nil) {
		self.imageName = imageName
		self.title = title
		self.identification = identification
		super.init()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
