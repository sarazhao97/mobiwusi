//
//  MOGetSummaryMessageRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/10.
//

import UIKit

@objcMembers
class MOGetSummaryMessageRequest: MOBaseRequestModel {
	dynamic var page:Int = 0
	dynamic var limit:Int = 0
	dynamic var user_paste_board_id:Int = 0
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.userData/getSummaryMessage"
		}
		set {
			super.hostRelativeUrl = newValue
		}
	}
}
