//
//  MOGhibliHistory.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

import UIKit

@objcMembers
class MOGhibliHistoryRequest: MOBaseRequestModel {
	dynamic var page:Int = 0
	dynamic var limit:Int = 0
	
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.ghibli/history" // 默认值（如果父类 url 为 nil）
		}
		set {
			super.hostRelativeUrl = newValue  // 可选链自动处理 nil
		}
	}
}
