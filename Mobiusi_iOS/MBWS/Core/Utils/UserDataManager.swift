import Foundation

final class UserManager: @unchecked Sendable {
    static let shared = UserManager()
    private init() {}
    
    // MARK: - 保存用户数据
    func saveUserData(_ userData: LoginData) {
        let defaults = UserDefaults.standard
        
        // 保存用户基本信息
        if let userID = userData.id {
            defaults.set(userID, forKey: "user_id")
        }
        
        if let username = userData.name {
            defaults.set(username, forKey: "user_username")
        }
        
        if let mobile = userData.mobile {
            defaults.set(mobile, forKey: "user_mobile")
        }
        
        if let email = userData.email {
            defaults.set(email, forKey: "user_email")
        }
        
        if let avatar = userData.avatar {
            defaults.set(avatar, forKey: "user_avatar")
        }
        
        // 保存token
        if let token = userData.token {
            defaults.set(token, forKey: "user_token")
        }
        
        // 保存登录状态
        defaults.set(true, forKey: "is_logged_in")
        
        // 同步保存
        defaults.synchronize()
        
        print("用户数据保存成功")
    }
    
    // MARK: - 获取用户数据
    func getUserID() -> Int {
        return UserDefaults.standard.integer(forKey: "user_id")
    }
    
    func getUsername() -> String? {
        return UserDefaults.standard.string(forKey: "user_username")
    }
    
    func getMobile() -> String? {
        // 注意：MOUserModel 通过 NS_ASSUME_NONNULL 标注为非可选，不能用 if let
        let user = MOUserModel.unarchive()
        let mobile = user.mobile
        if !mobile.isEmpty {
            return mobile
        }
        // 回退到 UserDefaults（兼容旧逻辑或未写入 MOUserModel 的场景）
        return UserDefaults.standard.string(forKey: "user_mobile")
    }
    
    func getEmail() -> String? {
        return UserDefaults.standard.string(forKey: "user_email")
    }
    
    func getAvatar() -> String? {
        return UserDefaults.standard.string(forKey: "user_avatar")
    }
    
    func getToken() -> String? {
        // 优先从 MOUserModel 获取 token（登录成功后实际保存的地方）
        let userModel = MOUserModel.unarchive()
        if userModel != nil {
            return userModel.token
        }
        // 如果 MOUserModel 中没有，则从 UserDefaults 获取（向后兼容）
        return UserDefaults.standard.string(forKey: "user_token")
    }
    
    // MARK: - 检查登录状态
    func isLoggedIn() -> Bool {
        // 优先检查 MOUserModel 中是否有有效的 token
        if let token = getToken(), !token.isEmpty {
            return true
        }
        // 如果 MOUserModel 中没有，则检查 UserDefaults（向后兼容）
        return UserDefaults.standard.bool(forKey: "is_logged_in")
    }
    
    // MARK: - 清除用户数据（退出登录）
    func clearUserData() {
        // 清除 MOUserModel 中的数据
        MOUserModel.remove()
        
        // 清除 UserDefaults 中的数据
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "user_id")
        defaults.removeObject(forKey: "user_username")
        defaults.removeObject(forKey: "user_mobile")
        defaults.removeObject(forKey: "user_email")
        defaults.removeObject(forKey: "user_avatar")
        defaults.removeObject(forKey: "user_token")
        defaults.removeObject(forKey: "is_logged_in")
        
        // 同步清除
        defaults.synchronize()
        
        print("用户数据清除成功")
    }
}
