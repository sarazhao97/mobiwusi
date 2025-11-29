//
//  MOParsePasteboardContentModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/28.
//

import Foundation
@objcMembers
class MOParsePasteboardContentModel: MOModel {
    dynamic var model_id:Int = 0
    dynamic var cate:Int = 0
	//1成功 2失败
	dynamic var status:Int = 0
	dynamic var duration:Int = 0
    var content:String?
    var file_name:String?
    var media_type:String?
    var preview_url:String?
    var resource_url:String?
    var title:String?
    var urls:String?
    var user_id:String?
    var extract_content:String?
	
	
    
    open class func modelCustomPropertyMapper()->[String:String] {
        
        return ["model_id":"id"]
    }
    
}
