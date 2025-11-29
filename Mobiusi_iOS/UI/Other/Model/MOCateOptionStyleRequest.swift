//
//  MOCateOptionStyleRequest.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

import UIKit

@objcMembers
class MOCateOptionStyleRequest: MOBaseRequestModel {

	override var hostRelativeUrl: String? {
		
		get {
			return "v1.cateOption/style" // 默认值（如果父类 url 为 nil）
		}
		set {
			super.hostRelativeUrl = newValue  // 可选链自动处理 nil
		}
	}
	
	override var responseClass: AnyClass? {
		get {
			return MOCateOptionStyleModel.self
		}
		set {
			super.responseClass = newValue
		}
	}
}
