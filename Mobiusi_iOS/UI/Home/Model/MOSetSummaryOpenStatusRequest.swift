//
//  MOSetSummaryOpenStatusRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/10.
//

import UIKit
@objcMembers
class MOSetSummaryOpenStatusRequest: MOBaseRequestModel {
	dynamic var model_id = 0
	dynamic var is_open = false
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.userData/setSummaryOpenStatus"
		}
		set {
			super.hostRelativeUrl = newValue
		}
	}
}
