//
//  MOGetSummaryListRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/8.
//

import UIKit
@objcMembers
class MOGetSummaryListRequest: MOBaseRequestModel {
	dynamic var page:Int = 0
	dynamic var limit:Int = 0
	// dynamic var is_square:Bool = false
	dynamic var square_user_id:Int = 0
	
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.userData/getSummaryList"
		}
		set {
			super.hostRelativeUrl = newValue
		}
	}
	
	override var responseClass: AnyClass? {
		get {
			return MOGetSummaryListItemModel.self
		}
		set {
			super.responseClass = newValue
		}
	}
}
