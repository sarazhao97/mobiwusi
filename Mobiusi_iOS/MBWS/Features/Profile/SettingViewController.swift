import SwiftUI
import SafariServices
import WebKit
import UserNotifications

struct SettingOption: Identifiable{
    var id: Int
    var title: String
    var isDetail: Bool?
    var isSwitchOn: Bool?
    var intro: String?
   
   
}

struct SettingOptionView: View{
    var option: SettingOption
    @Binding var switchState: Bool
    var onTap: () -> Void
    @State private var newVersion: String?

    
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            HStack{
                Text(option.title)
                    .font(.system(size: 16))
                    .foregroundColor(Color.black)
                Spacer()
                if option.isSwitchOn == true {
                    Toggle("", isOn: $switchState)
                         .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#9A1E2E")))
                }
                
                if let intro = option.intro{
                Text(intro)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black)
                    .fontWeight((option.id == 7 || option.id == 8 || option.id == 9) ? .bold : .regular)
                    .padding(.top, 5)
                }
                if option.isDetail == true {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color.black)
                        .padding(.top, 5)
                }

            }
           
        }
        .padding(.vertical, 15)
        .contentShape(Rectangle())
        .onTapGesture {
            if option.isSwitchOn != true {
                onTap()
            }
        }
    }
}

struct SettingViewController: View {
    @Environment(\.dismiss) var dismiss

    @State var isSwitchOn: Bool = false
    @State var navigateToNotification: Bool = false
    @State var showLogoutAlert: Bool = false  // 控制退出登录对话框显示
    @State var navigateToUserAgreement: Bool = false
    @State var navigateToPrivacyPolicy: Bool = false
    @State var showCacheClearAlert: Bool = false
    @State var navigateToFeedback: Bool = false
    @State var showNotificationPermissionAlert: Bool = false
    @State private var isUserTogglingSwitch: Bool = false
    @State private var navigateToLogOffAccount: Bool = false
    @State private var errorMessage = ""
    @State private var loading = false
 



    @State var options: [SettingOption] = [
        SettingOption(id:1, title: "消息通知", isDetail: true),
        SettingOption(id:2, title: "联系我们", isDetail: false, intro: "contact@mobiwusi.com"),
        SettingOption(id:3, title: "意见反馈", isDetail: true),
        SettingOption(id:4, title: "用户协议", isDetail: true),
        SettingOption(id:5, title: "隐私政策", isDetail: true),
        SettingOption(id:6, title: "推送通知", isSwitchOn: true),
        SettingOption(id:7, title: "检查更新", isDetail: true, intro: "V" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0")),
        SettingOption(id:8, title: "清理缓存", isDetail: true,intro:"0MB"),
        SettingOption(id:9, title: "APP备案号", isDetail: false,intro:"浙ICP备2024117967号-2A")
    ]
    var body: some View {
        NavigationView {
            ZStack{
                Color(hex: "#F7F8FA")
                    .ignoresSafeArea()
                
                  VStack(alignment: .leading, spacing: 0) {
                         ScrollView(showsIndicators:false){
                        VStack(spacing:10){
                            ForEach(options){ option in
                                SettingOptionView(
                                    option: option,
                                    switchState: Binding(
                                        get: { isSwitchOn },
                                        set: { newValue in
                                            isUserTogglingSwitch = true
                                            isSwitchOn = newValue
                                        }
                                    )
                                ) {
                                    switch option.id{
                                    case 1:
                                        navigateToNotification = true
                                        break
                                    case 2:
                                        openContactEmail()
                                        break
                                    case 3:
                                        navigateToFeedback = true
                                        break
                                    case 4:
                                        navigateToUserAgreement = true
                                        break
                                    case 5:
                                        navigateToPrivacyPolicy = true
                                        break
                                    case 6:
                                        // 行点击不触发开关切换，开关由 Toggle 控制
                                        break
                                    case 7:
                                        checkAppVersion()
                                        break
                                    case 8:
                                        showCacheClearAlert = true
                                        break
                                     default:
                                         break
                                    }
                                }
                            }
                        }
                         .padding(.horizontal,20)
                         .frame(maxWidth:.infinity)
                         .background(Color.white)
                         .cornerRadius(10)
                         .padding(.horizontal,10)
                   
                         HStack{
                                Text("退出登录")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex:"#9A1E2E"))
                            }
                                .padding(20)
                                .frame(maxWidth:.infinity)
                                .background(Color.white)
                                .cornerRadius(20)
                                .padding(.top,10)
                                .padding(.bottom,10)
                                .padding(.horizontal,10)
                                .onTapGesture {
                                    showLogoutAlert = true
                                }
                         HStack{
                                Text("注销账号")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.red)
                            }
                                .padding(20)
                                .frame(maxWidth:.infinity)
                                .background(Color.white)
                                .cornerRadius(20)
                                .padding(.bottom,10)
                                .padding(.horizontal,10)
                                .onTapGesture {
                                    navigateToLogOffAccount = true
                                }
                            }
                           
                                    
                    

                            NavigationLink(destination: TutorialWebViewPage(urlString: "https://m.mobiwusi.com/index/serviceAgreements",title: "用户协议"), isActive: $navigateToUserAgreement) {
                                EmptyView()
                            }
                            .hidden()
                            NavigationLink(destination: TutorialWebViewPage(urlString: "https://m.mobiwusi.com/index/privacyAgreements",title: "隐私政策"), isActive: $navigateToPrivacyPolicy) {
                                EmptyView()
                            }
                            .hidden()
                            NavigationLink(destination: FeedbackController(), isActive: $navigateToFeedback) {
                                EmptyView()
                            }
                            .hidden()
                             NavigationLink(destination: LogOffAccountView(), isActive: $navigateToLogOffAccount) {
                                EmptyView()
                            }
                            .hidden()
                    Spacer()
                  }

                    
             
             if showLogoutAlert {
                       CustomLogoutAlert(
                           showAlert: $showLogoutAlert,
                           onConfirm: {
                               performLogout()
                           }
                       )
                   }
            if showCacheClearAlert {
                CustomCacheClearAlert(
                    showAlert: $showCacheClearAlert,
                    onConfirm: {
                        clearAppCache { 
                            // 清理完成后直接设置为0MB
                            if let idx = options.firstIndex(where: { $0.id == 8 }) {
                                options[idx].intro = "0MB"
                            }
                            MBProgressHUD.showMessag("清理完成", to: nil, afterDelay: 1.5)
                        }
                    }
                )
            }
            if showNotificationPermissionAlert {
                NotificationPermissionAlert(
                    showAlert: $showNotificationPermissionAlert,
                    onReject: {
                        showNotificationPermissionAlert = false
                        isSwitchOn = false
                    },
                    onAgree: {
                        showNotificationPermissionAlert = false
                        requestNotificationAuthorization()
                    }
                )
            }

            if loading {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex:"#ffffff")))
                    Text("加载中")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                .padding(30)
                .frame(width:120,height:120)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
            }
                 
                 
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.black)
                    }
                }
            }
            .onAppear{
                checkNotificationPermissionStatus()
                checkAppVersion(showToast: false)
            }
            .onChange(of: isSwitchOn) { newValue in
                if isUserTogglingSwitch {
                    if newValue {
                        showNotificationPermissionAlert = true
                    } else {
                        UIApplication.shared.unregisterForRemoteNotifications()
                        MBProgressHUD.showMessag("已关闭推送通知", to: nil, afterDelay: 1.2)
                    }
                    isUserTogglingSwitch = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    checkNotificationPermissionStatus()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        NavigationLink(destination:NotificationController(), isActive: $navigateToNotification) {
            EmptyView()
        }

        
       
       
    }

        func checkNotificationPermissionStatus() {
            // 在后台队列进行权限查询，避免主线程阻塞（ Especially页面转场期间）
            DispatchQueue.global(qos: .utility).async {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    let status = settings.authorizationStatus
                    let alertEnabled = (settings.alertSetting == .enabled)
                    let soundEnabled = (settings.soundSetting == .enabled)

                    // 轻量日志输出
                    switch status {
                    case .notDetermined:
                        print("推送权限：未决定")
                    case .denied:
                        print("推送权限：已拒绝")
                    case .authorized:
                        print("推送权限：已授权")
                    case .provisional:
                        print("推送权限：临时授权")
                    case .ephemeral:
                        print("推送权限：临时授权（App Clip）")
                    @unknown default:
                        print("未知权限状态")
                    }

                    if alertEnabled { print("允许横幅通知") }
                    if soundEnabled { print("允许声音通知") }

                    // 在主线程同步开关状态：授权或临时授权 -> 开启；其他 -> 关闭
                    let authorizedLike = (status == .authorized || status == .provisional)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isSwitchOn = authorizedLike
                    }

                    // 如果被拒绝，回到主线程并弹出 SwiftUI 面板
                    if status == .denied {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showNotificationPermissionAlert = true
                        }
                    }
                }
            }
        }



    // 执行退出登录的方法
    private func performLogout() {
         loading = true
        errorMessage = ""
        
         NetworkManager.shared.post(APIConstants.Login.logOut, 
                                 businessParameters: [:]) { (result: Result<LogOutResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.code == 1{
                         // // 清除用户数据
                        NetworkManager.shared.clearUserData()
                        
                        // // 发送登录通知，触发跳转到登录页面
                        NotificationCenter.default.post(name: .loginRequired, object: nil)
                        
                        // print("用户确认退出登录，已清除用户数据并发送通知")
                    } else {
                        errorMessage = response.msg
                        MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                    }
                case .failure(let error):             
                    errorMessage = error.localizedDescription
                    MBProgressHUD.showMessag("\(errorMessage)", to: nil, afterDelay: 3.0)
                }
                loading = false
            }
        }
    }

    // 检查APP版本更新
    private func checkAppVersion(showToast: Bool = true) {
        // 当前版本信息
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let currentBuildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let currentBuildCode = Int(currentBuildString) ?? 0

        // 构建业务参数（2 = iOS，1 = AppId）
        let requestBody: [String: Any?] = [
            "app_type": 2,
            "app_id": 1
        ]

        NetworkManager.shared.post(APIConstants.Profile.checkAppVersion,
                                   businessParameters: requestBody) { (result: Result<CheckVersionResponse, APIError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let data = response.data else {
                        if showToast {
                            MBProgressHUD.showMessag("当前app已是最新版本", to: nil, afterDelay: 2.0)
                        }
                        return
                    }

                    let serverVersion = data.ver_name ?? ""
                    let newBuildCode = data.ver_code ?? 0

                    // 版本名按数字规则比较（1.2.10 > 1.2.9）
                    let needUpdateByName = !serverVersion.isEmpty && ((currentVersion as NSString).compare(serverVersion, options: .numeric) == .orderedAscending)
                    let needUpdateByCode = newBuildCode > currentBuildCode

                    if needUpdateByName && needUpdateByCode {
                        let isForce = (data.is_force ?? 0) == 1
                        self.showAppUpdateAlert(isForce: isForce,
                                                downloadURL: data.download_url ?? "",
                                                versionDescription: data.ver_describe ?? "")
                    } else {
                        if showToast {
                            MBProgressHUD.showMessag("当前app已是最新版本", to: nil, afterDelay: 2.0)
                        }
                    }

                    // 更新设置项中的版本显示（仅当服务端返回版本名时）
                    if !serverVersion.isEmpty, let idx = options.firstIndex(where: { $0.id == 7 }) {
                        options[idx].intro = "V" + serverVersion
                    }

                 case .failure(let error):
                     if showToast {
                         MBProgressHUD.showMessag(error.localizedDescription, to: nil, afterDelay: 2.0)
                     }
                 }
             }
         }
     }

    // 显示APP版本更新提示弹窗
    private func showAppUpdateAlert(isForce: Bool, downloadURL: String, versionDescription: String) {
        let alertTitle = isForce ? "强制更新" : "可选更新"
        let alertMessage = isForce ? "发现新版本，必须更新才能继续使用。\n\(versionDescription)" : "发现新版本，是否更新？\n\(versionDescription)"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "更新", style: .default, handler: { _ in
            if let url = URL(string: downloadURL) {
                UIApplication.shared.open(url)
            }
        }))
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }



}

// 自定义退出登录对话框
struct CustomLogoutAlert: View {
    @Binding var showAlert: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showAlert = false
                }
            
            // 对话框内容
            VStack(spacing: 20) {
                // 标题
                Text("温馨提示")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // 内容文本
                Text("是否确定退出登录？")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // 按钮区域
                HStack(spacing: 15) {
                    // 取消按钮
                    Button(action: {
                        showAlert = false
                    }) {
                        Text("取消")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex:"#EDEEF4"))
                            .cornerRadius(10)
                           
                    }
                    
                    // 确定按钮
                    Button(action: {
                        showAlert = false
                        onConfirm()
                    }) {
                        Text("确定")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#9A1E2E"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 40)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        
             
        }
    }
}



#Preview {
    SettingViewController()
}


extension SettingViewController {
    // 打开系统邮件客户端，预填收件人；若不可用则复制邮箱并提示
    private func openContactEmail() {
        let email = "contact@mobiwusi.com"
        let mailtoString = "mailto:\(email)"
        if let url = URL(string: mailtoString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    if !success {
                        UIPasteboard.general.string = email
                        MBProgressHUD.showMessag("未能打开邮件客户端，邮箱地址已复制", to: nil, afterDelay: 2.0)
                    }
                })
            } else {
                UIPasteboard.general.string = email
                MBProgressHUD.showMessag("未检测到可用邮件客户端，邮箱地址已复制", to: nil, afterDelay: 2.0)
            }
        } else {
            UIPasteboard.general.string = email
            MBProgressHUD.showMessag("邮箱地址无效，已复制以便手动粘贴", to: nil, afterDelay: 2.0)
        }
    }
}

// 自定义清理缓存对话框
struct CustomCacheClearAlert: View {
    @Binding var showAlert: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showAlert = false }
            
            VStack(spacing: 20) {
                Text("温馨提示")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
            
                Text("是否确定清理缓存？")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            
                HStack(spacing: 15) {
                    Button(action: { showAlert = false }) {
                        Text("取消")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex:"#EDEEF4"))
                            .cornerRadius(10)
                           
                    }
            
                    Button(action: {
                        showAlert = false
                        onConfirm()
                    }) {
                        Text("确定")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#9A1E2E"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
             .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 40)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

             
        }
    }
}





extension SettingViewController {
  func checkAndPromptNotificationPermission() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        DispatchQueue.main.async {
            if settings.authorizationStatus == .denied {
                // 显示 SwiftUI 的自定义 alert
                self.showNotificationPermissionAlert = true
            } else if settings.authorizationStatus == .notDetermined {
                // 请求权限
                requestNotificationAuthorization()
            }
        }
    }
}


private func innerCheckAndPrompt() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        DispatchQueue.main.async {
            if settings.authorizationStatus == .denied {
                showNotificationPermissionAlert = true
            } else if settings.authorizationStatus == .notDetermined {
                requestNotificationPermission()
            }
        }
    }
}

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        DispatchQueue.main.async {
            if !granted {
                showNotificationPermissionAlert = true
            }
        }
    }
}

    
    private func requestNotificationAuthorization() {
        // 跳转到系统的本应用设置页面，引导用户手动开启通知权限
        // 说明：iOS 未提供直接跳转到“通知”子页的公共 API，
        // 使用 UIApplication.openSettingsURLString 可到达本应用设置页，
        // 用户可在其中进入“通知”进行授权。
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            MBProgressHUD.showMessag("无法构造系统设置地址", to: nil, afterDelay: 1.5)
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                DispatchQueue.main.async {
                    if success {
                        MBProgressHUD.showMessag("请在系统设置中开启通知权限", to: nil, afterDelay: 1.5)
                    } else {
                        MBProgressHUD.showMessag("无法打开系统设置，请手动前往设置", to: nil, afterDelay: 1.5)
                    }
                }
            }
        } else {
            // 极少数情况下 canOpenURL 返回 false，给出回退提示
            DispatchQueue.main.async {
                MBProgressHUD.showMessag("设置不可用，请手动前往设置-通知中开启", to: nil, afterDelay: 1.8)
            }
        }
    }


}

struct NotificationPermissionAlert: View {
    @Binding var showAlert: Bool
    let onReject: () -> Void
    let onAgree: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showAlert = false }
            
            VStack(spacing: 20) {
                Text("温馨提示")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                Text("为了方便您接收推送消息，我们需要您提供通知权限。")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                     .lineSpacing(12)
                
                HStack(spacing: 15) {
                    Button(action: {
                        showAlert = false
                        onReject()
                    }) {
                        Text("拒绝")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#9A1E2E"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex:"#EDEEF4"))
                            .cornerRadius(10)
                            
                    }
                    
                    Button(action: {
                        showAlert = false
                        onAgree()
                    }) {
                        Text("同意")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#9A1E2E"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
             .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal, 40)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}



extension SettingViewController {
    // 计算并更新“清理缓存”菜单项的大小显示
    private func updateCacheSizeDisplay() {
        DispatchQueue.global(qos: .utility).async {
            let sizeText = SettingViewController.calculateCacheSizeText()
            DispatchQueue.main.async {
                if let idx = options.firstIndex(where: { $0.id == 8 }) {
                    options[idx].intro = sizeText
                }
            }
        }
    }

    // 计算缓存大小（Caches + tmp + URLCache）
    nonisolated static func calculateCacheSizeText() -> String {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
        
        var totalBytes: Int64 = 0
        if let cachesURL { totalBytes += Self.directorySize(at: cachesURL) }
        totalBytes += Self.directorySize(at: tmpURL)
        
        // 估算内存缓存（URLCache）大小
        totalBytes += Int64(URLCache.shared.currentDiskUsage + URLCache.shared.currentMemoryUsage)
        
        return Self.formatBytes(totalBytes)
    }

    nonisolated static func directorySize(at url: URL) -> Int64 {
        var size: Int64 = 0
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                do {
                    let values = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    size += Int64(values.fileSize ?? 0)
                } catch {
                    continue
                }
            }
        }
        return size
    }

    nonisolated static func formatBytes(_ bytes: Int64) -> String {
        if bytes <= 0 { return "0MB" }
        let mb = Double(bytes) / (1024.0 * 1024.0)
        if mb < 1 { return String(format: "%.2fMB", mb) }
        return String(format: "%.1fMB", mb)
    }

    // 清理缓存
    private func clearAppCache(completion: @escaping () -> Void) {
        // 清理 URLCache
        URLCache.shared.removeAllCachedResponses()
        
        // 清理 Caches 目录
        if let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            clearDirectory(at: cachesURL)
        }
        
        // 清理 tmp 目录
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
        clearDirectory(at: tmpURL)
        
        // 清理 WKWebView 数据缓存
        let dataTypes: Set<String> = [
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeSessionStorage
        ]
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) {
            completion()
        }
    }

    private func clearDirectory(at url: URL) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for item in contents {
                try? FileManager.default.removeItem(at: item)
            }
        } catch {
            // 忽略错误，继续清理其他内容
        }
    }
}
