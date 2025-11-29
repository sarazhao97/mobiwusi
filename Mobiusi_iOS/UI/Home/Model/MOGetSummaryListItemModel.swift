//
//  MOGetSummaryListItemModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/8.
//

import UIKit
@objcMembers
class MOGetSummaryListItemModel: MOModel {
	dynamic var model_id:Int = 0
	var title:String?
	var media_type:String?
	var resource_url:String?
	var preview_url:String?
	var update_time:String?
	var create_time:String?
	dynamic var user_id:Int = 0
	dynamic var cate:Int = 0
	dynamic var summarize_status:Int = 0
	var summary:String?
	var tags:String?
	var mind_map:String?
	var mind_content:String?
	dynamic var mind_status:Int = 0
	dynamic var is_open:Bool = false
	dynamic var like_num:Int = 0
	dynamic var unlike_num:Int = 0
	dynamic var is_like:Bool = false
	dynamic var is_unlike:Bool = false
	dynamic var share_num:Int = 0
	var user_avatar:String?
	var user_name:String?
	var source:String?
	var share_url:String?
	var paste_board_url:String?
	dynamic var is_mine:Bool = false
	var result:[MOGetSummaryListItemResultModel]?
	
	
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
	
	class func modelContainerPropertyGenericClass()->[String:Any]{
		
		return [
			"param":MOSummaryParamModel.self,
			"result":MOGetSummaryListItemResultModel.self
		]
	}
}

@objcMembers
class MOGetSummaryListItemResultModel: MOModel {
	dynamic var model_id:Int = 0
	dynamic var duration:Int = 0
	dynamic var cate:Int = 0
	var path:String?
	var data_param:String?
	var file_name:String?
	var snapshot:String?
	var preview_url:String?
	
	open class func modelCustomPropertyMapper()->[String:String] {
		
		return ["model_id":"id"]
	}
}
