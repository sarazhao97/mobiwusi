//
//  MOAudioAnnotationItemModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/26.
//

import Foundation
@objcMembers
class MOAudioAnnotationItemModel: MOModel {
    dynamic var model_id:Int = 0
	dynamic var meta_data_id:Int = 0
	dynamic var result_id:Int = 0
	
//	status ‘0’:’加工中’,’1’:’待审核’,’2’:’已审核’,’3’:’已驳回’
	dynamic var status:Int = 0
	var status_zh:String?
    var audio_rate:String?
    var data_param:String?
    var task_title:String?
    dynamic var cate:Int = 0
    var audio_format:String?
    var path:String?
	//本地属性
	var localCachePath:String?
    dynamic var size:UInt64 = 0
    var price:String?
    dynamic var task_id:Int = 0
    var file_name:String?
    var property:[MOAudioProperty]?
    dynamic var duration:Int64 = 0
    var create_time:String?
    var data_model_option_ids:String?
    var currency_unit:String?
	dynamic var user_data_id:Int = 0
	
	
    class func modelCustomPropertyMapper()->[String:String] {
        
        return ["model_id":"id"]
    }
    
    class func modelContainerPropertyGenericClass()->[String:MOModel.Type] {
        
        return ["property":MOAudioProperty.self]
    }
}


@objcMembers
class MOAudioProperty:MOModel {
    var name:String?
    var value:String?
}
