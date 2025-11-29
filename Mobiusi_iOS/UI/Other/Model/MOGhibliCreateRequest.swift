//
//  MOGhibliCreateRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

import UIKit

@objcMembers
class MOGhibliCreateRequest: MOBaseRequestModel {
	dynamic var style_id:Int = 0
	var url:String?
	var parent_post_id:String?
	
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.ghibli/create" // 默认值（如果父类 url 为 nil）
		}
		set {
			super.hostRelativeUrl = newValue  // 可选链自动处理 nil
		}
	}
}
