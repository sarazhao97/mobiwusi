//
//  MOAudioProcessPropertyModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/4.
//

import Foundation
@objcMembers
class MOAudioProcessPropertyModel: MOModel {
	var cate_alias:String?
	dynamic var model_id:Int = 0
	dynamic var isParent:Bool = false
	var name:String?
	dynamic var open:Bool = false
	dynamic var parent_id:Int = 0
	var state:String?
	dynamic var value:Int = 0
	var children:[MOAudioProcessPropertyModel]?
	//本地属性
	dynamic var isSelected:Bool = false
	
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
	
	class func modelContainerPropertyGenericClass()->[String:Any]{
		return [
			"children":MOAudioProcessPropertyModel.self,
		]
	}
}
