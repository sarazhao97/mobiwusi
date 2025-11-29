//
//  MOAnnotationDetailModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/4.
//

import Foundation
@objcMembers
class MOAnnotationDetailModel: MOModel {
	dynamic var duration:Int64 = 0
	var path:String?
	dynamic var annotation_order_id:Int = 0
	dynamic var data_id:Int = 0
	dynamic var cate:Int = 0
	dynamic var model_id:Int = 0
	//status ‘0’:’加工中’,’1’:’待审核’,’2’:’已审核’,’3’:’已驳回’
	dynamic var status:Int = 0
	var status_zh:String?
	dynamic var task_id:Int = 0
	dynamic var user_data_id:Int = 0
	dynamic var user_id:Int = 0
	var audio_slice:[MOAudioClipSegmentCustomModel]?
	var localCachePath:String?
	var sound_decibels:[Int]?
	class func modelContainerPropertyGenericClass()->[String:Any]{
		
		return [
			"audio_slice":MOAudioClipSegmentCustomModel.self,
		]
	}
	
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
}
