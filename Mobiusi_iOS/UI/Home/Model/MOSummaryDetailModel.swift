//
//  MOSummaryDetailModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/29.
//

import Foundation
@objcMembers
class MOSummaryDetailModel: MOModel {
    dynamic var model_id:Int = 0
	dynamic var is_like:Bool = false
	dynamic var is_mine:Bool = false
	dynamic var is_open:Bool = false
	dynamic var is_unlike:Bool = false
	dynamic var like_num:Int = 0
	dynamic var share_num:Int = 0
	dynamic var unlike_num:Int = 0
    var tags:String?
    var source:String?
    var summary:String?
    var mind_map:String?
	var share_url:String?
	var paste_board_url:String?
	var result:[MOGetSummaryListItemResultModel]?
    var param:[MOSummaryParamModel]?
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
class MOSummaryParamModel: MOModel {
    var name:String?
    var value:String?
    
}
