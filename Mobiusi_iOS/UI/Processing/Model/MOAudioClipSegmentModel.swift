//
//  MOAudioClipSegmentModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/4.
//

import Foundation
@objcMembers
class MOAudioClipSegmentModel: MOModel {
	dynamic var model_id:Int64 = 0
	dynamic var start_time:Int64 = 0
	dynamic var end_time:Int64 = 0
	var audio_text:String?
	var audio_property:[MOAudioAudioSegmentPropertyModel]?
	dynamic var is_valid:Bool = false
	var invalid_reason:String?
	var remark:String?
	var tags:[String]?
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
	
	class func modelContainerPropertyGenericClass()->[String:Any]{
		
		return [
			"audio_property":MOAudioAudioSegmentPropertyModel.self,
		]
	}
}

@objcMembers
class MOAudioAudioSegmentPropertyModel: MOModel {
	var name:String?
	var selectData:String?
	dynamic var value:String?
}

@objcMembers
class MOAudioClipSegmentCustomModel: MOAudioClipSegmentModel {
	
	//本地自定义
	dynamic var wave_start_time:Int64 = 0
	//本地自定义
	dynamic var wave_end_time:Int64 = 0
	//本地自定义
	dynamic var audio_text_height = 100.0
	//本地自定义
	var invalid_reason_height = 199.0
	//本地自定义
	dynamic var remark_height = 100.0
	//本地自定义
	dynamic var isExpand = true
	//本地自定义 -1表示未分割的
	dynamic var localIndex = -1
	//本地自定义属性
	var audio_property_original:[MOAudioProcessPropertyModel]?
	override class func modelContainerPropertyGenericClass()->[String:Any]{
		var all = super.modelContainerPropertyGenericClass()
		all.updateValue(MOAudioClipSegmentModel.self, forKey: "audio_property_original")
		return all
	}
}
