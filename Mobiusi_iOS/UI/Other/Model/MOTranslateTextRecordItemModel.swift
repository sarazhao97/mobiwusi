//
//  MOTranslateTextRecordItemModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/6/17.
//

import UIKit

@objcMembers
class MOTranslateTextRecordItemModel: MOModel {
	dynamic var Model_id = 0
	dynamic var user_id = 0
	var path:String?
	var original_text:String?
	var translate_text:String?
	var result_url:String?
	var result_path:String?
	var share_url:String?
	var create_time:String?
	var update_time:String?
	dynamic var status = 0
	var status_text:String?
}
