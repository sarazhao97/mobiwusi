//
//  MOCateOptionStyleModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

import UIKit

@objcMembers
class MOCateOptionStyleModel: MOModel {
	dynamic var model_id:Int = 0
	var name:String?
	var name_zh:String?
	var req_key:String?
	var sub_req_key:String?
	var trigger_word:String?
	var url:String?
	
	class func modelCustomPropertyMapper()->[String:String]{
		return ["model_id":"id"]
	}
}
