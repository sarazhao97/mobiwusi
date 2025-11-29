//
//  MOSummaryOperationRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/9.
//

import UIKit

@objcMembers
class MOSummaryOperationRequest: MOBaseRequestModel {
	dynamic var model_id = 0
	//1点赞 2不感兴趣 3分享
	dynamic var operation_type = 0
	// 1：选中 0取消，分享类型的传1
	dynamic var operation_status = 0
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
	
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.userData/summaryOperation"
		}
		set {
			super.hostRelativeUrl = newValue
		}
	}
}
