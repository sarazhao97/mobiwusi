//
//  MOGhibliHistoryModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

import UIKit
@objcMembers
class MOGhibliHistoryModel: MOModel {
	var id:Int = 0
	dynamic var model_id:Int = 0
	var create_time:String?
	var image_path:String?
	var path_url:String?
	var original_image:String?
	var share_url:String?
	//1:成功 2：失败 3：生成中
	dynamic var status:Int = 0
	var status_zh:String?
}
