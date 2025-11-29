import Foundation
import UIKit

/// 处理需要重新登录的情况
class LoginRequiredHandler {
    static let shared = LoginRequiredHandler()
    private init() {}
    
    /// 开始监听登录通知
    func startListening() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginRequired),
            name: .loginRequired,
            object: nil
        )
    }
    
    /// 停止监听登录通知
    func stopListening() {
        NotificationCenter.default.removeObserver(self, name: .loginRequired, object: nil)
    }
    
    @objc private func handleLoginRequired() {
        DispatchQueue.main.async {
            self.presentLoginViewController()
        }
    }
    
    private func presentLoginViewController() {
        // 获取当前显示的视图控制器
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // 查找当前显示的视图控制器
        var currentVC = rootViewController
        while let presentedVC = currentVC.presentedViewController {
            currentVC = presentedVC
        }
        
        // 创建登录页面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "MOLoginVC") as? UIViewController {
            // 使用模态方式呈现登录页面
            loginVC.modalPresentationStyle = .fullScreen
            currentVC.present(loginVC, animated: true)
        }
    }
}
