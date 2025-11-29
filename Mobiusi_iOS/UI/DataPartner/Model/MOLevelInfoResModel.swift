//
//  MOLevelInfoResModel.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/5/12.
//

import Foundation
@objcMembers
class MOLevelInfoResModel: MOModel {
    dynamic var model_id:Int = 0
    dynamic var mobi_point:Int = 0
    dynamic var continuous_days:Int = 0
    dynamic var level:Int = 0
    dynamic var level_point:Int = 0
    var levels:[MOLevelInfoModel]?
    var week_data:[MOLevelWeekDataModel]?
    var taskdata:[MOLevelTaskDataModel]?
    class func modelCustomPropertyMapper()->[String:String]{
        return ["model_id":"id"]
    }
    class func modelContainerPropertyGenericClass()->[String:Any]{
        
        return [
            "levels":MOLevelInfoModel.self,
            "week_data":MOLevelWeekDataModel.self,
            "taskdata":MOLevelTaskDataModel.self
        ]
    }
    
}

@objcMembers
class MOLevelInfoModel: MOModel {
    dynamic var level:Int = 0
    dynamic var point:Int = 0
    var desc:String?
}
@objcMembers
class MOLevelWeekDataModel: MOModel {
    var week_day:String?
    var date:String?
    dynamic var val:Int = 0
    //状态 1已签到 0未签
    dynamic var status:Int = 0
    dynamic var is_today:Bool = false
    dynamic var is_yesterday:Bool = false
}
@objcMembers
class MOLevelTaskDataModel: MOModel {
    var key:String?
    var title:String?
    var icon:String?
    dynamic var point:Int = 0
    //状态 0未填写 1审核中 2已通过 3未通过
    dynamic var status:Int = 0
}


