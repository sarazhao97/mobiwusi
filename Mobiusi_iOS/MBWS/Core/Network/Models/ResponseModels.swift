import Foundation

// MARK: - 任务状态值（支持Int和String混合类型）
enum TaskStatusValue: Decodable, Equatable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(TaskStatusValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or String"))
        }
    }
    
    // 获取字符串表示
    var stringValue: String {
        switch self {
        case .int(let value):
            return String(value)
        case .string(let value):
            return value
        }
    }
    
    // 获取整数值（如果可能）
    var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        case .string(let value):
            return Int(value)
        }
    }
    
    // 检查是否为空
    var isEmpty: Bool {
        switch self {
        case .int(_):
            return false
        case .string(let value):
            return value.isEmpty
        }
    }
}

// 获取验证码接口返回模型
struct CodeResponse: Decodable {
    let code: CodeValue
    let msg: String
    let reqtime: String
    
    // 自定义 CodeValue 类型，支持 Int 和 String
    enum CodeValue: Decodable {
        case int(Int)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else {
                throw DecodingError.typeMismatch(CodeValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Code must be either Int or String"))
            }
        }
        
        // 比较方法，支持与 Int 和 String 比较
        func isEqual(to value: Any) -> Bool {
            switch self {
            case .int(let intValue):
                if let otherInt = value as? Int {
                    return intValue == otherInt
                } else if let otherString = value as? String {
                    return String(intValue) == otherString
                }
            case .string(let stringValue):
                if let otherString = value as? String {
                    return stringValue == otherString
                } else if let otherInt = value as? Int {
                    return stringValue == String(otherInt)
                }
            }
            return false
        }
    }
}

// 登录接口返回模型
struct LoginResponse: Decodable {
    let code: Int
    let msg: String
    let reqtime: String
    let data: LoginData?
}

//忘记密码返回模型
struct ForgetResponse: Decodable {
    let code: Int
    let msg: String
    let reqtime: String
    let data: Any?

    // 定义 CodingKeys
    private enum CodingKeys: String, CodingKey {
        case code
        case msg
        case reqtime
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try container.decode(Int.self, forKey: .code)
        msg = try container.decode(String.self, forKey: .msg)
        reqtime = try container.decode(String.self, forKey: .reqtime)
        
        // 尝试解析为 Bool
        if let boolValue = try? container.decode(Bool.self, forKey: .data) {
            data = boolValue
        }
        // 尝试解析为字典
        else if let dictValue = try? container.decode([String: String].self, forKey: .data) {
            data = dictValue
        } else {
            data = nil
        }
    }
}

//注册接口返回模型
struct RegisterResponse: Decodable {
    let code:Int
    let msg:String
    let data:[String: String]?  // 通用字典
    let reqtime: String
}

// 登录数据模型
struct LoginData: Decodable {
    let token: String?
    let id: Int?
    let name: String?
    let mobile: String?
    let avatar: String?
    let email: String?
}

//注册数据模型
struct RegisterData: Decodable {
    let id: Int
    let name: String?
    let mobile: String?
    let avatar: String?
    let token: String?
}

// MARK: - Index接口相关模型

// Index接口响应模型
struct IndexResponse: Decodable {
    let code: Int
    let msg: String
    let data: [IndexItem]
    let reqtime: String
}

// Index数据项模型
struct IndexItem: Decodable, Identifiable {
    let post_id: String
    let id: Int
    let create_time: String
    let task_title: String?
    let location: String?
    let cate: Int
    let parent_post_id: String
    let user_task_id: Int?
    let task_id: Int?
    let description: String?
    let idea: String?
    let source: Int?
    let is_authentication:Int?
    let meta_data: [MetaData]?
    let fraction: Int
    let is_feature: Int?
    let ai_tool:AItool?
     let annotation: AnnotationInfo?
    let transaction: TransactionInfo?
    let continuity: ContinuityInfo?
    let knowledge_graph: KnowledgeGraphInfo?
   
   
    
    private enum CodingKeys: String, CodingKey {
        case post_id
        case id
        case create_time
        case task_title
        case cate
        case parent_post_id
        case source
        case meta_data
        case location
        case user_task_id
        case task_id
        case description
        case idea
        case is_authentication
        case fraction
        case is_feature
        case ai_tool
        case annotation
        case transaction
        case continuity
        case knowledge_graph 
    }
}

// 标注信息模型
struct AnnotationInfo: Decodable {
    let total: Int?
    let isRead: Bool?
    let avatar: String?
    let time: String?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case isRead = "is_read"
        case avatar
        case time
    }
}

// 交易信息模型
struct TransactionInfo: Decodable {
    let total: Int?
    let isRead: Bool?
    let avatar: String?
    let time: String?
    let price: Double?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case isRead = "is_read"
        case avatar
        case time
        case price
    }
}

// 连续信息模型
struct ContinuityInfo: Decodable {
    let total: Int?
    let time: String?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case time
    }
}

// 知识图谱信息模型
struct KnowledgeGraphInfo: Decodable {
    let total: Int?
    let time: String?
    
    private enum CodingKeys: String, CodingKey {
        case total
        case time
    }
}

struct AItool: Decodable {
    let name: String
    let update_time: String
}

// 元数据模型
struct MetaData: Decodable {
    let feature: String?
    let original_image_path: String?
    let image_path: String?
    let style_name: String?
    let is_video: Int?
    let duration: Int?
    let preview_url: String?
    let file_name: String?
    let title: String?
    let content: String?
    let path: String?
    let relative_path: String?
    let score: Int?
    let tips: String?
    let task_text: String?
    let cate: Int? // 新增：用于直接判断媒体类型（1音频，2图片，3文本，4视频）
    
    private enum CodingKeys: String, CodingKey {
        case feature
        case original_image_path
        case image_path
        case style_name
        case is_video
        case duration
        case preview_url
        case file_name
        case title
        case content
        case path
        case relative_path
        case score
        case tips
        case task_text
        case cate // 新增：后端若返回 cate，与模型对齐
    }
    
}

// MARK: - 食品安全分析结果响应模型
struct FoodAnalysisResultResponse: Decodable {
    let code: Int
    let msg: String
    let data: FoodAnalysisResultData?
    let reqtime: String
}

struct FoodAnalysisResultData: Decodable {
    let id: Int
    let user_id: Int
    let status: Int
    let uuid: String
    let image_path: String
    let update_time: String
    let create_time: String
    let delete_time: String?
    let is_delete: Int
    let score: Int
    let safe_level: [SafeLevelItem]
    let warn_level: [WarnLevelItem]
    let danger_level: [DangerLevelItem]
    let nutrient_percent: [NutrientPercentItem]
    let suggested_crowd: [String]
    let unsuggested_crowd: [String]
    let image_url: String
    let status_zh: String
    let score_describe: String
    let share_url: String
    let share_timestamp: Int
    let share_nonce: Int
    let share_sharejson: String
    let share_sign: String
    
    // 计算属性：安全等级描述
    var safetyLevelDescription: String {
        if score >= 80 {
            return "安全"
        } else if score >= 60 {
            return "一般"
        } else {
            return "需要注意"
        }
    }
    
    // 计算属性：是否有风险配料
    var hasDangerousIngredients: Bool {
        return !danger_level.isEmpty
    }
    
    // 计算属性：是否有警示配料
    var hasWarningIngredients: Bool {
        return !warn_level.isEmpty
    }
}

// MARK: - 安全配料
struct SafeLevelItem: Decodable {
    let name: String
}

// MARK: - 警示配料
struct WarnLevelItem: Decodable {
    let name: String
    let intro: String
}

// MARK: - 风险配料
struct DangerLevelItem: Decodable {
    let name: String
    let intro: String
    let describe: String
    let reason: [String]
}

// MARK: - 营养成分
struct NutrientPercentItem: Decodable {
    let name: String
    let percent: String
    let weight: String
}

// MARK: - 任务场景分类响应模型
struct SceneTypesResponse: Decodable {
    let code: Int
    let msg: String
    let data: SceneTypesData?
    let reqtime: String
}

struct SceneTypesData: Decodable {
    let task_count: Int
    let yesterday_count: Int
    let scene_data: [SceneTypeItem]
    
    private enum CodingKeys: String, CodingKey {
        case task_count
        case yesterday_count
        case scene_data
    }
}
// MARK: - 任务列表响应模型
struct TaskListResponse: Decodable {
    let code: Int
    let msg: String
    let data: [TaskItem]
    let reqtime: String
}

// MARK: - 任务项模型
struct TaskItem: Decodable, Identifiable {
    let id: Int
    let title: String
    let task_type: Int
    let recording_requirements: String?
    let task_no: String
    let topic_num: Int
    let unit: String
    let user_id: Int
    let price: Double
    let currency_unit: String
    let data_detail: String
    let publish: String
    let task_ask: String?
    let receiving_orders_desc: String?
    let cate: Int?
    let user_task_id: Int?
    let task_status: Int?
    let user_task_num: Int
    let is_get: Int
    let simple_descri: String
    let is_follow: Int
    let file_type: String
    let example_url: String?
    let is_need_describe: Int
    let limit_of_one_upload_image: Int
    let limit_of_one_upload_video: Int
    let limit_of_one_upload_file: Int
    let is_try: Int
    let try_status: Int
    let is_plain_text: Int
    let cover_image: String?
    let remaining_places: Int?
    let person_limit: Int?
    
    // 计算属性：是否允许领取任务
    var canTakeTask: Bool {
        return is_get == 1
    }
    
    // 计算属性：是否已关注
    var isFollowed: Bool {
        return is_follow == 1
    }
    
    // 计算属性：是否需要试做
    var needTryTask: Bool {
        return is_try == 1
    }
    
    // 计算属性：是否为纯文本任务
    var isPlainTextTask: Bool {
        return is_plain_text == 1
    }
    
    // 计算属性：是否需要描述
    var needDescription: Bool {
        return is_need_describe == 1
    }
    
    // 计算属性：任务状态描述
    var taskStatusDescription: String {
        guard let status = task_status else { return "未知" }
        switch status {
        case 1: return "进行中"
        case 2: return "待审核"
        case 3: return "未通过"
        case 4: return "已通过"
        case 5: return "已完成"
        default: return "未知"
        }
    }
    
    // 计算属性：试做状态描述
    var tryStatusDescription: String {
        switch try_status {
        case 1: return "试做通过"
        case 2: return "驳回"
        case 3: return "审核中"
        default: return "未试做"
        }
    }
    
    // 计算属性：任务类型描述
    var taskTypeDescription: String {
        switch task_type {
        case 1: return "采集项目"
        case 2: return "加工项目"
        default: return "未知类型"
        }
    }
    
    // 计算属性：数据类型描述
    var categoryDescription: String {
        switch cate {
        case 0: return "全部"
        case 1: return "音频"
        case 2: return "图片"
        case 3: return "文件"
        case 4: return "视频"
        default: return "未知"
        }
    }
    
    // 计算属性：允许的文件类型数组
    var allowedFileTypes: [String] {
        return file_type.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}



// MARK: - 用户个人资料响应模型
struct UserProfileResponse: Decodable {
    let code: Int
    let msg: String
    let data: UserProfileData?
    let reqtime: String
}

// MARK: - 用户个人资料数据模型
struct UserProfileData: Decodable {
    let id: Int
    let name: String
    let describe: String?
    let avatar: String?
    let mobile: String?
    let sex: Int?
    let region: String?
    let email: String?
    let realname: String?
    let is_auth: Int?
    let cert_type: Int?
    let cert_no: String?
    let certify_id: String?
    let relative_path: String?
    let create_time: String?
    let unionid: String?
    let openid: String?
    let lord_identity: String?
    let account_balance: String?
    let yesterday_income: String?
    let data_count: Int?
    let follow_task_id: String?
    let zone_size_used: Int?
    let zone_size_total: Int?
    let native_city: String?
    let native_city_code: String?
    let native_province: String?
    let native_province_code: String?
    let zone_size_used_txt: String?
    let zone_size_total_txt: String?
    let task_follow_count: Int?
    let uid: Int
    let is_auth_zh: String?
    let token: String
    let all_tag_count: Int?
    let has_tag_count: Int?
    let no_tag_count: Int?
    let has_tag_count_recently: Int?
    let today_income: String?
    let month_income: String?
    let income_val: String?
    let withdrawal_val: String?
    let task_count: Int?
    let mobi_point: Int?
    let level_point: Int?
    let level: Int?
    let continuous_days: Int?
    let country_code: String?
    let alipay_openid: String?
    let sub: String?
    let huawei_unionid: String?
    let moid: String?
}

// MARK: - 修改个人信息响应模型
struct UpdateUserInfoResponse: Decodable {
    let code: Int
    let msg: String
    let data: UpdateUserInfoData?
    let reqtime: String
}

// MARK: - 修改个人信息数据模型
struct UpdateUserInfoData: Decodable {
    let empty: String?
}

//MARK: - 资产模块
struct AssetsResponse: Decodable {
    let code: Int
    let msg: String
    let data: AssetsData?
    let reqtime: String
}

struct AssetsData: Decodable {
    let today_income: String?
    let withdrawal_val: String?
    let yesterday_income: String?
    let month_income: String?
    let income_val: String?
    let account_balance: String?
}

// MARK: - 消息列表响应模型
struct MessageListResponse: Decodable {
    let code: Int
    let msg: String
    let data: MessageListData?
    let reqtime: String
}

struct MessageListData: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let page_total: Int
    let list: [MessageItem]
}

// MARK: - 消息项模型
struct MessageItem: Decodable, Identifiable {
    let type_id: Int
    let create_time: String
    let relate_id: Int
    let task_id: Int?
    let type_name: String
    let title: String
    let content: String
    let icon: String
    let image: String?
    let content_images: [String]?
    
    // 随机生成的唯一ID
    let uniqueId: String
    
    // 自定义初始化方法
    init(type_id: Int, create_time: String, relate_id: Int, task_id: Int?, type_name: String, title: String, content: String, icon: String, image: String?, content_images: [String]?) {
        self.type_id = type_id
        self.create_time = create_time
        self.relate_id = relate_id
        self.task_id = task_id
        self.type_name = type_name
        self.title = title
        self.content = content
        self.icon = icon
        self.image = image
        self.content_images = content_images
        self.uniqueId = UUID().uuidString
    }
    
    // 从JSON解码时的初始化
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type_id = try container.decode(Int.self, forKey: .type_id)
        create_time = try container.decode(String.self, forKey: .create_time)
        relate_id = try container.decode(Int.self, forKey: .relate_id)
        task_id = try container.decodeIfPresent(Int.self, forKey: .task_id)
        type_name = try container.decode(String.self, forKey: .type_name)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        icon = try container.decode(String.self, forKey: .icon)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        content_images = try container.decodeIfPresent([String].self, forKey: .content_images)
        uniqueId = UUID().uuidString
    }
    
    // CodingKeys枚举
    private enum CodingKeys: String, CodingKey {
        case type_id, create_time, relate_id, task_id, type_name, title, content, icon, image, content_images
    }
    
    // 计算属性：消息ID（使用随机生成的唯一ID）
    var id: String {
        return uniqueId
    }
    
    // 计算属性：消息类型枚举
    var messageType: MessageType {
        switch type_id {
        case 1: return .systemNotice
        case 2: return .taskReview
        case 3: return .taskCompleted
        case 4: return .withdrawal
        case 5: return .taskError
        case 6: return .dataPurchased
        case 7: return .newPaidTask
        case 8: return .taskDeadline
        case 9: return .dataSummaryOld
        case 10: return .dataProcessing
        case 11: return .dataSummary
        default: return .unknown
        }
    }
    
    // 计算属性：是否有图片
    var hasImage: Bool {
        return image != nil && !image!.isEmpty
    }
    
    // 计算属性：是否有内容图片
    var hasContentImages: Bool {
        return content_images != nil && !content_images!.isEmpty
    }
    
    // 计算属性：格式化时间
    var formattedTime: String {
        // 这里可以添加时间格式化逻辑
        return create_time
    }
}

// MARK: - 我的项目响应模型
struct MyProjectResponse: Decodable {
    let code: Int
    let msg: String
    let data: [MyProjectItem]
    let reqtime: String
}

// MARK: - 我的项目数据项模型
struct MyProjectItem: Decodable, Identifiable {
    let id: Int
    let price: Double?
    let currency_unit: String?
    let unit: String?
    let receive_time: String?
    let is_try: Int?
    let try_status: Int?
    let is_plain_text: Int?
    let data_detail: String?
    let recording_requirements: String?
    let simple_descri: String?
    let cate: Int?
    let title: String?
    let task_no: String?
    let task_id: Int?
    let user_task_num: Int?
    let limit_of_one_upload_image: Int?
    let limit_of_one_upload_video: Int?
    let is_need_describe: Int?
    let file_type: String?
    let example_url: String?
    let finished: Int?
    let try_finished: Int?
    let count: Int?
    let try_topic_num: Int?
    let limit_of_one_upload_file: Int?
    let task_type: Int?
    let cover_image: String?
    let topic_num: Int?
    let is_follow: Int?
    
    // 计算属性：是否需要试做
    var needTryTask: Bool {
        return is_try == 1
    }
    
    // 计算属性：是否为纯文本任务
    var isPlainTextTask: Bool {
        return is_plain_text == 1
    }
    
    // 计算属性：是否需要描述
    var needDescription: Bool {
        return is_need_describe == 1
    }
    
    // 计算属性：是否已关注
    var isFollowed: Bool {
        return is_follow == 1
    }
    
    // 计算属性：试做状态描述
    var tryStatusDescription: String {
        guard let status = try_status else { return "未知" }
        switch status {
        case 1: return "测试通过"
        case 2: return "驳回"
        case 3: return "审核中"
        default: return "未测试"
        }
    }
    
    // 计算属性：任务状态描述（根据finished字段）
    var taskStatusDescription: String {
        guard let finishedValue = finished else { return "未知" }
        switch finishedValue {
        case 0: return "未开始"
        case 1: return "进行中"
        case 2: return "待审核"
        case 3: return "未通过"
        case 4: return "初审通过"
        case 5: return "已完成"
        default: return "未知"
        }
    }
    
    // 计算属性：数据类型描述
    var categoryDescription: String {
        guard let category = cate else { return "未知" }
        switch category {
        case 1: return "音频"
        case 2: return "图片"
        case 3: return "文本"
        case 4: return "视频"
        default: return "未知"
        }
    }
    
    // 计算属性：完成进度百分比
    var completionPercentage: Double {
        guard let topicNum = topic_num, let finishedValue = finished, topicNum > 0 else { return 0.0 }
        return Double(finishedValue) / Double(topicNum) * 100.0
    }
    
    // 计算属性：试做完成进度百分比
    var tryCompletionPercentage: Double {
        guard let tryTopicNum = try_topic_num, let finishedCount = try_finished, tryTopicNum > 0 else { return 0.0 }
        return Double(finishedCount) / Double(tryTopicNum) * 100.0
    }
    
    // 计算属性：是否有封面图
    var hasCoverImage: Bool {
        guard let coverImage = cover_image else { return false }
        return !coverImage.isEmpty
    }
    
    // 计算属性：是否有示例URL
    var hasExampleUrl: Bool {
        guard let exampleUrl = example_url else { return false }
        return !exampleUrl.isEmpty
    }
    
    // 计算属性：允许的文件类型数组
    var allowedFileTypes: [String] {
        guard let fileType = file_type else { return [] }
        return fileType.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    // 计算属性：格式化价格
    var formattedPrice: String {
        guard let price = price, let currencyUnit = currency_unit else { return "价格未知" }
        return "\(currencyUnit)\(price)"
    }
    
    // 计算属性：任务类型描述
    var taskTypeDescription: String {
        guard let taskType = task_type else { return "未知类型" }
        switch taskType {
        case 1: return "采集项目"
        case 2: return "加工项目"
        default: return "未知类型"
        }
    }
    
    // 计算属性：是否有价格信息
    var hasPrice: Bool {
        return price != nil && price! > 0
    }
    
    // 计算属性：试做完成数量
    var tryFinishedCount: Int {
        return try_finished ?? 0
    }
    
    // 计算属性：总计数
    var totalCount: Int {
        return count ?? 0
    }
}

// MARK: - 我的项目请求参数模型
struct MyProjectRequest: Encodable {
    let page: Int?
    let limit: Int?
    let cate_id: Int
    let task_status: Int?
    
    init(page: Int? = nil, limit: Int? = nil, cate_id: Int, task_status: Int? = nil) {
        self.page = page
        self.limit = limit
        self.cate_id = cate_id
        self.task_status = task_status
    }
}

// MARK: - 任务状态枚举
enum TaskStatus: Int, CaseIterable {
    case inProgress = 1    // 进行中
    case pendingReview = 2 // 待审核
    case rejected = 3       // 未通过
    case firstPassed = 4   // 初审通过
    case completed = 5     // 已完成
    
    var displayName: String {
        switch self {
        case .inProgress: return "进行中"
        case .pendingReview: return "待审核"
        case .rejected: return "未通过"
        case .firstPassed: return "初审通过"
        case .completed: return "已完成"
        }
    }
}

// MARK: - 任务类别枚举
enum TaskCategory: Int, CaseIterable {
    case audio = 1  // 音频
    case image = 2  // 图片
    
    var displayName: String {
        switch self {
        case .audio: return "音频"
        case .image: return "图片"
        }
    }
}

// MARK: - 试做状态枚举
enum TryStatus: Int, CaseIterable {
    case notTried = 0      // 未试做
    case passed = 1         // 测试通过
    case rejected = 2        // 驳回
    case underReview = 3    // 审核中
    
    var displayName: String {
        switch self {
        case .notTried: return "未试做"
        case .passed: return "测试通过"
        case .rejected: return "驳回"
        case .underReview: return "审核中"
        }
    }
}

// MARK: - 消息类型枚举
enum MessageType: Int, CaseIterable {
    case systemNotice = 1      // 系统公告
    case taskReview = 2        // 任务审核通过/拒绝
    case taskCompleted = 3     // 任务完成，获得收益
    case withdrawal = 4        // 提现成功/失败
    case taskError = 5         // 任务出现多次错误
    case dataPurchased = 6     // 数据被购买
    case newPaidTask = 7       // 新的付费任务出现
    case taskDeadline = 8      // 任务临近结束时间
    case dataSummaryOld = 9    // 用户数据总结[废弃]
    case dataProcessing = 10   // 加工数据
    case dataSummary = 11      // 用户数据总结
    case unknown = 0           // 未知类型
    
    var displayName: String {
        switch self {
        case .systemNotice: return "系统公告"
        case .taskReview: return "任务审核"
        case .taskCompleted: return "任务完成"
        case .withdrawal: return "提现通知"
        case .taskError: return "任务错误"
        case .dataPurchased: return "数据交易"
        case .newPaidTask: return "新任务"
        case .taskDeadline: return "任务提醒"
        case .dataSummaryOld: return "数据总结"
        case .dataProcessing: return "数据加工"
        case .dataSummary: return "数据总结"
        case .unknown: return "未知"
        }
    }
    
    var iconName: String {
        switch self {
        case .systemNotice: return "megaphone"
        case .taskReview: return "checkmark.circle"
        case .taskCompleted: return "dollarsign.circle"
        case .withdrawal: return "creditcard"
        case .taskError: return "exclamationmark.triangle"
        case .dataPurchased: return "cart"
        case .newPaidTask: return "bell"
        case .taskDeadline: return "clock"
        case .dataSummaryOld: return "doc.text"
        case .dataProcessing: return "gearshape"
        case .dataSummary: return "doc.text"
        case .unknown: return "questionmark"
        }
    }
}

// MARK: - 任务详情响应模型
struct TaskDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: TaskDetailData?
    let reqtime: String
}

// MARK: - 任务详情数据
struct TaskDetailData: Decodable, Equatable {
    let id: Int
    let task_type: Int
    let task_id: Int
    let cover_image: String?
    let is_plain_text: Int?
    let title: String?
    let recording_requirements: String?
    let picture_requirements: String?
    let text_requirements: String?
    let video_requirements: String?
    let limit_of_one_upload_file: Int?
    let file_type: String?
    let receive_times: Int?
    let topic_num: Int?
    let task_no: String?
    let currency_unit: String?
    let unit: String?
    let user_id: Int?
    let price: Double?
    let data_detail: String?
    let publish: String?
    let task_ask: String?
    let receiving_orders_desc: String?
    let cate: Int?
    let simple_descri: String?
    let user_task_status: Int?
    let task_status: TaskStatusValue?
    let user_task_id: Int?
    let user_receive_times: Int?
    let is_need_describe: Int?
    let limit_of_one_upload_image: Int?
    let limit_of_one_upload_video: Int?
    let purpose: String?
    let is_get: Int?
    let is_follow: Int?
    let is_pay: Int?
    let finished: Int?
    let topic_list_data: [TaskTopicItem]?
    let topic_list_count: Int?
    let topic_list_complete: Int?
    let topic_list_reject_total: Int?
    let recording_requirements_read_status: Int?
    let picture_requirements_read_status: Int?
    let text_requirements_read_status: Int?
    let video_requirements_read_status: Int?
    let sample_list: [TaskSampleItem]?
    let share_url: String?
    let share_timestamp: Int?
    let share_nonce: Int?
    let share_sharejson: String?
    let share_sign: String?
}

// MARK: - 任务详情题目项
struct TaskTopicItem: Decodable, Identifiable, Equatable {
    let id: Int
    let relate_id: Int?
    let path: String?
    let cate: Int?
    let status: Int?
    let file_name: String?
    let duration: Int?
    let remark: String?
    let size: Int?
    let text: String?
    let demand: String?
    let url: String?
    let snapshot: String?
}

// MARK: - 任务详情示例项
struct TaskSampleItem: Decodable, Equatable {
    let path_url: String?
    let path_thumb: String?
    let caption: String?
    let file_name: String?
    let cate: Int?
    let duration: Int?
}

// MARK: - 上传文件-获取预签名url响应模型
struct GetPresignedUrlsResponse: Decodable {
    let code: Int
    let msg: String
    let data: [PresignedUrlItem]
    let reqtime: String
}

struct PresignedUrlItem: Decodable {
    let file_name: String
    let file_size: Int
    let file_hash: String
    let path: String
    let upload_url: String
    let preview_url: String
    let file_id: Int
}

// MARK: - 上传文件-预览响应模型
struct GetPreviewUrlResponse: Decodable {
    let code: Int
    let msg: String
    let data: GetPreviewUrlData?
    let reqtime: String
}

struct GetPreviewUrlData: Decodable {
    let url: String
    let relative_url: String
}

//MARK: - 更新元数据响应模型
struct UpdateTaskMetadataResponse: Decodable {
    let code: Int
    let msg: String
    let data: UpdateMetaEmptyData?
    let reqtime: String
}

// 与更新元数据接口返回示例一致：{"data": {"empty": ""}}
struct UpdateMetaEmptyData: Decodable {
    let empty: String?
}

// MARK: - 领取任务响应数据类型（支持Int和字典混合类型）
enum ReceiveTaskDataValue: Decodable {
    case int(Int)
    case dict([String: String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let dictValue = try? container.decode([String: String].self) {
            self = .dict(dictValue)
        } else {
            throw DecodingError.typeMismatch(ReceiveTaskDataValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or Dictionary"))
        }
    }
    
    // 获取整数值（如果可能）
    var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        case .dict(_):
            return nil
        }
    }
    
    // 检查是否为空字典
    var isEmpty: Bool {
        switch self {
        case .int(_):
            return false
        case .dict(let dict):
            return dict.isEmpty || (dict.count == 1 && dict["empty"] != nil)
        }
    }
}

// MARK: - 领取任务响应模型
struct ReceiveTaskResponse: Decodable {
    let code: Int
    let msg: String
    let data: ReceiveTaskDataValue
    let reqtime: String
}

// MARK: - 放弃标注任务响应模型
struct RecycleTaskResponse: Decodable {
    let code: Int
    let msg: String
    let data: Bool
    let reqtime: String
}

// MARK: - 关注/取消任务响应模型
struct FollowTaskResponse: Decodable {
    let code: Int
    let msg: String
    let data: Bool
    let reqtime: String
}

// MARK: - 完成项目接口响应模型
struct CompleteTaskResponse: Decodable {
    let code: Int
    let msg: String
    let data: CompleteTaskData
    let reqtime: String
}

struct CompleteTaskData: Decodable {
    let empty: String
}

// MARK: - 热门数据任务响应模型
struct HotTaskListResponse: Decodable {
    let code: Int
    let msg: String
    let data: [HotTaskItem]
    let reqtime: String
}

struct HotTaskItem: Decodable {
    let id: Int
    let title: String
    let task_no: String
    let cate: Int
    let is_get: Int
    let click_num: Int
    let unit: String
    let is_follow: Int
    let is_try: Int
    let try_status: Int
    let remaining_places: Int
}

// MARK: - 搜索综合响应模型
struct MultiSearchResponse: Decodable {
    let code: Int
    let msg: String
    let data: MultiSearchData
    let reqtime: String
}

struct MultiSearchData: Decodable {
    let audio_list: [MultiSearchTaskItem]
    let image_list: [MultiSearchTaskItem]
    let text_list: [MultiSearchTaskItem]
    let video_list: [MultiSearchTaskItem]
}

struct MultiSearchTaskItem: Decodable {
    let id: Int
    let title: String
    let recording_requirements: String?
    let limit_of_one_upload_file: Int
    let file_type: String?
    let example_url: String?
    let receive_times: Int
    let topic_num: Int
    let task_no: String
    let unit: String
    let user_id: Int
    let price: Int
    let data_detail: String
    let publish: String
    let task_ask: String?
    let receiving_orders_desc: String?
    let cate: Int
    let simple_descri: String
    let task_status: Int?
    let user_task_id: Int?
    let user_task_num: Int?
    let user_receive_times: Int?
    let is_need_describe: Int
    let limit_of_one_upload_image: Int?
    let limit_of_one_upload_video: Int?
    let try_topic_num: Int?
    let is_get: Int
    let is_follow: Int
    let is_try: Int
    let try_status: Int?
    let is_plain_text: Int
}

// MARK: - 我的数据统计响应模型
struct MyDataStatisticsResponse: Decodable {
    let code: Int
    let msg: String
    let data: [MyDataStatisticsItem]
    let reqtime: String
}

struct MyDataStatisticsItem: Decodable {
    let cate: Int
    let total: Int
}

// MARK: - 吉卜力详情接口响应模型
struct GhibliDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: GhibliDetailData?
    let reqtime: String
}

struct GhibliDetailData: Decodable {
    let id: Int
    let user_id: Int
    let prompt: String?
    let uuid: String
    let style_id: Int
    let llm_type: String?
    let original_image: String
    let image_path: String
    let update_time: String
    let create_time: String
    let delete_time: String?
    let is_delete: Int
    let status: Int
    let mongo_user_post_id: String?
    let parent_post_id: String
    let user_name: String
    let status_zh: String
    let style_name: String
    let style_url: String
    let path_url: String
    let result_url: String
    let status_text: String
    let share_url: String
    let share_timestamp: Int
    let share_nonce: Int
    let share_sharejson: String
    let share_sign: String
}

// MARK: - 总结消息列表响应模型
struct SummaryMessageListResponse: Decodable {
    let code: Int
    let msg: String
    let data: SummaryMessageListData?
    let reqtime: String
}

struct SummaryMessageListData: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let page_total: Int
    let list: [SummaryMessageItem]
    
    private enum CodingKeys: String, CodingKey {
        case total
        case page
        case limit
        case page_total
        case list
    }
}

struct SummaryMessageItem: Decodable, Identifiable {
    let id: Int
    let user_id: Int
    let user_paste_board_id: Int
    let operation_type: Int
    let create_time: String
    let operation_status: Int
    let user_name: String
    let user_avatar: String
    let operation_type_text: String
    let operation_content: String
    let icon: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case user_paste_board_id
        case operation_type
        case create_time
        case operation_status
        case user_name
        case user_avatar
        case operation_type_text
        case operation_content
        case icon
    }
    
    // 操作类型描述
    var operationTypeDescription: String {
        switch operation_type {
        case 1: return "点赞"
        case 2: return "不感兴趣"
        case 3: return "分享"
        default: return "未知操作"
        }
    }
    
    // 操作状态描述
    var operationStatusDescription: String {
        switch operation_status {
        case 1: return "操作"
        case 0: return "取消"
        default: return "未知状态"
        }
    }
    
    // 格式化时间显示
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = formatter.date(from: create_time) else {
            return create_time
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "刚刚"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)分钟前"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)小时前"
        } else {
            let days = Int(timeInterval / 86400)
            if days < 7 {
                return "\(days)天前"
            } else {
                formatter.dateFormat = "MM-dd"
                return formatter.string(from: date)
            }
        }
    }
}

// MARK: - 我的数据-总结相关操作响应模型
struct SummaryOperationResponse: Decodable {
    let code: Int
    let msg: String
    let data: Int
    let reqtime: String
}

// MARK: - 用户数据总结详情
struct UserDataSummaryDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: UserDataSummaryDetailData?
    let reqtime: String
}

struct UserDataSummaryDetailData: Decodable {
    let id: Int
    let summary: String
    let mind_map: String
    let param: [SummaryParam]
    let tags: String
    let source: String
    let share_url: String
    let like_num: Int
    let unlike_num: Int
    let is_like: Int
    let is_unlike: Int
    let is_open: Int
    let share_num: Int
    let share_timestamp: Int
    let share_nonce: Int
    let share_sharejson: String?
    let share_sign: String
    let user_avatar: String
    let user_name: String
    let user_id: Int
    let is_mine: Int
    let paste_board_url: String
    let result: [SummaryResultItem]
}

struct SummaryParam: Decodable, Hashable {
    let name: String
    let value: String
}

struct SummaryResultItem: Decodable {
    let path: String
    let data_param: String
    let duration: Int
    let cate: Int
    let id: Int
    let file_name: String
    let snapshot: String
    let preview_url: String?
}

// MARK: - 图片翻译记录详情接口响应模型
struct ImageTranslationDetailResponse: Decodable {
    let code: Int
    let msg: String
    let data: ImageTranslationDetailData?
    let reqtime: String
}

struct ImageTranslationDetailData: Decodable {
    let id: Int
    let user_id: Int
    let path: String
    let result_path: String
    let original_text: String
    let translate_text: String
    let create_time: String
    let update_time: String
    let status: Int
    let path_url: String
    let result_url: String
    let status_text: String
    let share_url: String
    let share_timestamp: Int
    let share_nonce: Int
    let share_sharejson: String
    let share_sign: String
}



// 音频转写接口返回模型
struct AudioTranscriptionResponse: Decodable {
    let code: Int
    let msg: String
    let data: String?
    let reqtime: String

    private enum CodingKeys: String, CodingKey { case code, msg, data, reqtime }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        msg = try container.decode(String.self, forKey: .msg)
        reqtime = try container.decode(String.self, forKey: .reqtime)
        // 容错：当 data 返回为对象或 null 时，安全置为 nil，避免类型不匹配崩溃
        data = try? container.decode(String.self, forKey: .data)
    }
}




// MARK: - 自由上传数据响应模型
struct FreeUploadDataResponse: Decodable {
    let code: Int
    let msg: String
    let data: String?
    let reqtime: String

    private enum CodingKeys: String, CodingKey { case code, msg, data, reqtime }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        msg = try container.decode(String.self, forKey: .msg)
        reqtime = try container.decode(String.self, forKey: .reqtime)
        // 容错：服务返回可能是字符串 'true' 或布尔 true，统一转为字符串
        if let str = try? container.decode(String.self, forKey: .data) {
            data = str
        } else if let boolVal = try? container.decode(Bool.self, forKey: .data) {
            data = boolVal ? "true" : "false"
        } else {
            data = nil
        }
    }
}


// MARK: - 解析粘贴板内容响应模型
struct ParseClipboardResponse: Decodable {
    let code: Int
    let msg: String
    let data: ParseClipboardData?
    let reqtime: String
}

struct ParseClipboardData: Decodable {
    let title: String?
    let file_name: String?
    let media_type: String?      // 文件类型：audio/image/file/video
    let resource_url: String?    // 资源原始地址
    let preview_url: String?     // 资源封面
    let id: Int?
    let cate: Int?               // 1:音频 2:图片 3：文件 4：视频
    let extract_content: String? // 新闻URL提取的内容
    let extract_images: [String]?// 提取的图片集合（可能返回为字符串或数组）
    let status: Int?             // 1：解析成功 2：解析失败
    let extract_url: String?     // 内容中包含的URL
    let content: String?         // 原始内容
    let user_id: Int?
    let is_download: Int?
    let parent_post_id: String?

    private enum CodingKeys: String, CodingKey {
        case title, file_name, media_type, resource_url, preview_url, id, cate,
             extract_content, extract_images, status, extract_url, content,
             user_id, is_download, parent_post_id
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = try? c.decode(String.self, forKey: .title)
        file_name = try? c.decode(String.self, forKey: .file_name)
        media_type = try? c.decode(String.self, forKey: .media_type)
        resource_url = try? c.decode(String.self, forKey: .resource_url)
        preview_url = try? c.decode(String.self, forKey: .preview_url)
        id = try? c.decode(Int.self, forKey: .id)
        cate = try? c.decode(Int.self, forKey: .cate)
        extract_content = try? c.decode(String.self, forKey: .extract_content)
        status = try? c.decode(Int.self, forKey: .status)
        extract_url = try? c.decode(String.self, forKey: .extract_url)
        content = try? c.decode(String.self, forKey: .content)
        user_id = try? c.decode(Int.self, forKey: .user_id)
        is_download = try? c.decode(Int.self, forKey: .is_download)
        parent_post_id = try? c.decode(String.self, forKey: .parent_post_id)

        // extract_images 容错：后端可能返回 "" 字符串或以逗号分隔的字符串
        if let arr = try? c.decode([String].self, forKey: .extract_images) {
            extract_images = arr
        } else if let s = try? c.decode(String.self, forKey: .extract_images) {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                extract_images = []
            } else if trimmed.contains(",") {
                extract_images = trimmed.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else {
                extract_images = [trimmed]
            }
        } else {
            extract_images = nil
        }
    }
}

// MARK: - 写入粘贴板内容（Mobiwusi总结）响应模型
struct WritePasteboardContentResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataField?
    let reqtime: String

    enum DataField: Decodable {
        case bool(Bool)
        case ids([Int])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let b = try? container.decode(Bool.self) {
                self = .bool(b)
            } else if let arr = try? container.decode([Int].self) {
                self = .ids(arr)
            } else if let arrStr = try? container.decode([String].self) {
                let ints = arrStr.compactMap { Int($0) }
                self = .ids(ints)
            } else {
                throw DecodingError.typeMismatch(DataField.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Bool or [Int] for data"))
            }
        }

        var boolValue: Bool? {
            if case .bool(let b) = self { return b }
            return nil
        }

        var idsValue: [Int]? {
            if case .ids(let arr) = self { return arr }
            return nil
        }

        var isSuccess: Bool {
            if let b = boolValue { return b }
            if let arr = idsValue { return !arr.isEmpty }
            return false
        }
    }
}




// ... 上传文件响应模型 ...
struct UploadFileResponse: Decodable {
    let code: Int
    let msg: String
    let data: UploadFileData?
    let reqtime: String
}

struct UploadFileData: Decodable {
    let file_id: Int?
    let url: String?
    let relative_url: String?
    let original_name: String?
}

//连续记录响应模型
struct ContinuityRecordResponse: Decodable {
    let code: Int
    let msg: String
    let data: [ContinuityRecordData]?
    let reqtime: String
}

struct ContinuityRecordData: Decodable {
    let post_id: String?
    let id: Int?
    let meta_data: [MetaData]?
    let parent_post_id: String?
    let source: Int?
    // 可选扩展字段（备注中列出，可能返回）
    let user_task_id: Int?
    let create_time: String?
    let task_title: String?
    let location: String?
    let idea: String?
    let description: String?
}

// MARK: - APP版本更新检测响应模型
struct CheckVersionResponse: Decodable {
    let code: Int
    let msg: String
    let data: CheckVersionData?
    let reqtime: String
}

struct CheckVersionData: Decodable {
    let id: Int?
    let ver_name: String?
    let ver_code: Int?
    let is_force: Int?
    let download_url: String?
    let ver_describe: String?
    let begin_time: String?
    let enabled: Int?
    let app_name: String?
    let is_index_tips: Int?
    let app_type: Int?
}

// MARK: - 意见反馈提交响应模型
struct FeedbackSubmitResponse: Decodable {
    let code: Int
    let msg: String
    let data: FeedbackSubmitData?
    let reqtime: String
}

struct FeedbackSubmitData: Decodable {
    let id: Int
}

// MARK: - 墨比积分-获取信息响应模型
struct MobiPointsInfoResponse: Decodable {
    let code: Int
    let msg: String
    let data: MobiPointsInfoData?
    let reqtime: String
}

struct MobiPointsInfoData: Decodable {
    let id: Int
    let mobi_point: Int
    let continuous_days: Int
    let levels: [MobiLevelItem]
    let level: Int
    let level_point: Int
    let week_data: [MobiWeekItem]
    let task_data: [MobiTaskItem]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case mobi_point
        case continuous_days
        case levels
        case level
        case level_point
        case week_data
        case task_data
        case taskdata // 兼容后端返回的无下划线写法
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        mobi_point = try container.decode(Int.self, forKey: .mobi_point)
        continuous_days = try container.decode(Int.self, forKey: .continuous_days)
        levels = try container.decode([MobiLevelItem].self, forKey: .levels)
        level = try container.decode(Int.self, forKey: .level)
        level_point = try container.decode(Int.self, forKey: .level_point)
        week_data = try container.decode([MobiWeekItem].self, forKey: .week_data)
        if let v = try container.decodeIfPresent([MobiTaskItem].self, forKey: .task_data) {
            task_data = v
        } else if let v2 = try container.decodeIfPresent([MobiTaskItem].self, forKey: .taskdata) {
            task_data = v2
        } else {
            task_data = []
        }
    }
}

struct MobiLevelItem: Decodable {
    let level: Int
    let point: Int
    let desc: String
}

struct MobiWeekItem: Decodable {
    let week_day: String
    let date: String
    let val: Int
    let status: Int // 1已签到 0未签
    let is_today: Int
    let is_yesterday: Int
}

struct MobiTaskItem: Decodable {
    let key: String
    let title: String
    let point: Int
    let status: Int // 0未填写 1审核中 2已通过 3未通过
    let icon: String
}

// MARK: - 墨比积分-签到响应模型
struct MobiSignInResponse: Decodable {
    let code: Int
    let msg: String
    let data: MobiSignInData?
    let reqtime: String
}

struct MobiSignInData: Decodable {
    let value: Int
}


struct CategoryOptionResponse: Decodable {

    let code: Int
    let msg: String
    let data: CategoryOptionData?
    let reqtime: String
}

struct CategoryOptionData: Decodable {
   let feedback_type: [CategoryType]
   let complaint_type: [CategoryType]
   let user_file_type: [CategoryType]
   let task_type: [CategoryType]    
   let cert_type: [CategoryType]
   let general_image:String
   let withdrawal_money: [CategoryType]
   let audio_cate: [CategoryType]
   let image_cate: [CategoryType]
   let text_cate: [CategoryType]
   let video_cate: [CategoryType]
   let work_type: [CategoryType]
   let work_income: [CategoryType]
   
}

struct CategoryType: Decodable {
    let value: String
    let name: String
}

// MARK: - 通用认证-申请认证响应模型
struct ApplyVerificationResponse: Decodable {
    let code: Int
    let msg: String
    let data: ApplyVerificationData?
    let reqtime: String
}

struct ApplyVerificationData: Decodable {
    let empty: String
}

struct ShareStylesResponse: Decodable {
    let code: Int
    let msg: String
    let data: [ShareStyleItem]?
    let reqtime: String
}

struct ShareStyleItem: Decodable, Hashable {
    let image: String?
    let nick_name: String?
    let avatar: String?
    let qrcode_url: String?
}
struct ConfirmLoginResponse: Decodable {
    let code: Int
    let msg: String
    let data: ConfirmLoginData?
    let reqtime: String
}

struct ConfirmLoginData: Decodable {
    let empty: String
}

struct ScanCodeResponse: Decodable {
    let code: Int
    let msg: String
    let data: ScanCodeData?
    let reqtime: String
}

struct ScanCodeData: Decodable {
    let empty: String
}

struct FeatureDataResponse: Decodable {
    let code: Int
    let msg: String
    let data: [FeatureItem]?
    let reqtime: String
}

struct FeatureItem: Decodable {
    let file_name: String
    let duration: Int
    let file_url: String
    let feature: [FeatureAttr]
    let cate: Int
    let preview_url: String
    let thumbnail_url: String
}

struct FeatureAttr: Decodable {
    let name: String
    let value: String
}

// MARK: - 提现通道相关模型
struct WithdrawalChannelResponse: Decodable {
    let code: Int
    let msg: String
    let data: [WithdrawalChannelItem]?
    let reqtime: String
}

struct WithdrawalChannelItem: Decodable {
    let name: String
    let type: Int
    let icon: String?
    let isDefault: Int?  // 接口返回的是数字 1 或 0，不是字符串
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case icon
        case isDefault
    }
}

// MARK: - 注销账号响应模型
struct CancelUserResponse: Decodable {
    let code: Int
    let msg: String
    let data: CancelUserData?
    let reqtime: String
}

enum CancelUserData: Decodable {
    case list([String])
    case empty(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let arr = try? container.decode([String].self) {
            self = .list(arr)
        } else if let dict = try? container.decode([String: String].self) {
            let val = dict["empty"] ?? ""
            self = .empty(val)
        } else {
            throw DecodingError.typeMismatch(CancelUserData.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected array or object with 'empty'"))
        }
    }

    var isEmpty: Bool {
        switch self {
        case .list(let arr): return arr.isEmpty
        case .empty(let s): return s.isEmpty
        }
    }
}

struct LogOutResponse: Decodable {
    let code: Int
    let msg: String
    let data: LogOutData?
    let reqtime: String
}

struct LogOutData: Decodable {
    let empty: String
}

// MARK: - 第三方账号绑定-微信 响应模型
struct BindWeChatResponse: Decodable {
    let code: Int
    let msg: String
    let data: BindWeChatData?
    let reqtime: String
}

struct BindWeChatData: Decodable {
    let id: String
    let openid: String?
    let unionid: String?
}

