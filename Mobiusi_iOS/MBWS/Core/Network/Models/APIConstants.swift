import Foundation

struct APIConstants {
    // Base URL
    //  static let baseURL = "http://api.dev.mobiwusi.com"
       static let baseURL = "https://app-api.mobiwusi.com"

    
    /// 添加你的私钥 PEM
       static let privateKeyPEM = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBANemrv06SK8B1WIp3qatENT5iI7aiqEIweFEdxJ6EBrPTYQbcjBPmE0vYedoTDUPlOJDVG3PdofpobaDP8quc8YJcDEsFEFWI0wOLJlKX8KbFKkyTbAOYhprm8wC+JrwBVdcS9cbU8N5fulCUp1hKCN2YjxqcIDzZ2Q7GHCxqpsdAgMBAAECgYAFtlycSJb0S9AjMYi8UYlImvOLFS7m5Rx9oxqkWqdijms3PKLhtLoMEV0+i/y4yxjehXoPDpfNMdsewotGCyj14YdVm5ZNRj3HgP5JY2hbahCtpJuaJtMAKg1zYDNgVMmKxBf2tMB+C5w1mlFX1mK5xemm2xJ7CcMOGz7mTn5i4QJBAO0VXgyvC1JSevijSgtVWqDhxohpHYUHrYBDtsd4LqFMSzKczq93fMyStxQUxDlzVlCMtYrNnQSPyNRJUykcN0MCQQDo24q6itXJjxWwZ+0UUC7+UGvpahBovavhFAnIEqFe9nWBwqzjIXeebvdpYhoUc+Sl6z0IusN0bqGNAG9RmM4fAkEAutMntd8KkOimNuCWLLAqJrVD+aK7vGT8eCLkGfO+6yRv7YZb6THDioHi+1QR/SPCVN9NAABfR4T2wTK28aJmeQJAIqDTZp5S4KCIpy0tUoICGwu2oIWHXywlrVkfg0NSAB9CpkNfFn/ZnBQAcwmFu1jovcvXzb6IZn41RBS2eTnyHQJAUnrQlfaMFOC7wTFCvRsJ4hmckuEg7SqjMNfEeqM1zKX6QEVENxF9lsb14clOkjiJ3x6Sv34dikeFMG/UQZ+f+A=="

    // 登录模块接口
    struct Login {
        static let getCode = "/v1.login/getCode"     // 获取验证码
        static let login = "/v1.login/login"        // 登录
        static let register = "/v1.login/register"  // 注册账号
        static let forget = "/v1.login/resetPassword"   //忘记密码
        static let scanCode = "/v1.qrcodeLogin/scan" //PC扫码登录-扫码
        static let confirmLogin = "/v1.qrcodeLogin/confirm"    //PC扫码登录-确认
        static let featureData = "/v2.Index/feature" //数据特征
        static let logOff = "/v1.user/cancelUser" //注销账号
        static let logOut = "/v1.user/logout" //退出登录
        static let bindWechat = "/v1.user/bindWeChat" //第三方账号绑定-微信
        static let bindAlipay = "/v1.user/bindAlipay" //第三方账号绑定-支付宝
        static let unbindAccount = "/v1.user/unbindThirdAccount"//第三方账号解绑
        

    }

    // Index模块接口
    struct Index {
        static let index = "/v2.Index/index"  // 获取索引数据
        static let foodSafetyAnalysisDetail = "/v2.foodAnalysis/getRestul"  // 食品安全分析详情
        static let hotSearchList = "/v1.task/hotList"//搜索-热门数据任务
        static let searchComposite = "/v2.task/multiSearch"//搜索-综合
        static let myDataCount = "/v2.Index/myDataStatistics" //我的数据统计
        static let getVariationPhotographerDetail = "/v2.ghibli/detail" //多变摄影师的详情接口
        static let getImageTranslationDetail = "/v2.tool/transPictureDetail" //图片翻译记录详情
        static let getNewsAnalysisDetail = "/v2.userData/getSummaryDetail" //资讯分析详情接口
        static let likeNewsAnalysis = "/v2.userData/summaryOperation" //资讯分析-点赞/取消点赞
        //总结消息列表
        static let getSummaryMessageList = "/v2.userData/getSummaryMessage" //总结消息列表

        //解析粘贴板内容
        static let parseClipboard = "/v2.userData/parsePasteboardContent" //解析粘贴板内容
        //Mobiwusi 总结
        static let getNewsSummary = "/v2.userData/writePasteboardContent" //资讯分析-总结
        //上传文件
        static let uploadFile = "/v1.upload/upload"  //上传文件
        //连续记录
        static let getContinuityRecord = "v2.Index/continuityRecord" //连续记录
        static let getPreviewUrl = "/v1.upload/preview" //上传文件-预览


    }
    //场景模块接口
    struct Scene {
        static let getSceneTypes = "/v2.task/scenes"     //任务场景分类
        static let getTaskList = "/v2.task/all"    //任务列表
        static let getTaskDetail = "/v3.task/detail"  //任务详情
        static let getPresignedUrl = "/v1.upload/getPresignedUrls"  //上传文件-获取预签名url
        static let updateTaskMetadata = "/v3.task/updateMeta"  //更新元数据
        static let receiveTask = "/v3.task/receiveTask"  //领取任务
         static let abandonTask = "/v2.task/recycleTask"  //放弃标注任务
        static let followTask = "/v1.task/followTask"  //关注/取消任务  
        static let submitTask = "/v3.task/completeTask"  //提交任务   
        static let getAudioTranscription = "/v2.annotation/speechToText"  //音频转写
        static let freeUploadData = "/v2.UserData/unlimitedUploadData"  //自由上传数据
        //分享图片资源
        static let shareImage = "/v1.cateOption/shareStyles"  //分享图片资源
        
    }

    //我的模块
    struct Profile {
        static let getMyData = "/v1.user/userInfo"  // 获取我的数据
        static let getNotification = "/v1.message/list"  // 获取消息通知
        static let getMyProject = "/v1.task/myReceiveTask"  // 获取我的项目
        static let editUserInfo = "/v1.user/saveUser"     //修改个人信息　
        //APP版本更新
        static let checkAppVersion = "/v1.version/checkVersion"
        //意见反馈
        static let feedback = "/v1.feedback/save"
        //墨比积分-获取信息接口
        static let getMobiPointsInfo = "/v1.user/levelInfo"  // 获取墨比积分信息
        //墨比积分-签到接口
        static let signIn = "/v1.user/signIn"  // 签到
        //分类选项
        static let getCategoryOptions = "/v1.cateOption/index" //分类选项
        //申请认证接口
        static let applyVerification = "/v1.userAuth/saveAuth" //申请认证
        
    }

    //资产模块
    struct Assets {
        static let getAssets = "/v1.UserBalance/center"  // 获取我的资产
        static let withdrawalChannel = "/v1.cateOption/withdrawalChannel"  // 获取提现通道
        
    }

    // 网络请求超时时间
    static let timeout: TimeInterval = 30.0
}
