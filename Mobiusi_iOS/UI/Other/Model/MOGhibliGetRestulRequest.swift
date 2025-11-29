//
//  MOGhibliGetRestulRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/11.
//

import UIKit
@objcMembers
class MOGhibliGetRestulRequest: MOBaseRequestModel {

	var uuid:String?
	override var hostRelativeUrl: String? {
		
		get {
			return "v2.ghibli/getRestul" // 默认值（如果父类 url 为 nil）
		}
		set {
			super.hostRelativeUrl = newValue  // 可选链自动处理 nil
		}
	}
}
