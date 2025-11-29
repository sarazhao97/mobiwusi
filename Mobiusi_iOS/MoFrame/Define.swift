//
//  Define.swift
//  Mobiusi_iOS
//
//  Created by Mac on 2025/3/27.
//

import Foundation
import UIKit

// 获取 AppDelegate 实例
@MainActor
func MOAppDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

// 获取 AppDelegate 类
func MOAppDelegateClass() -> AppDelegate.Type {
    return AppDelegate.self
}

// 弱引用 self
func WEAKSELF<T: AnyObject>(_ selfRef: T) -> T? {
    weak var weakSelf = selfRef
    return weakSelf
}

extension Notification.Name {
    static let ApplyForWithdrawalSucess = Notification.Name("ApplyForWithdrawalSucess")
	static let UnlimitedUploadDataUploadSuccess = Notification.Name("UnlimitedUploadDataUploadSuccess")
	static let SummarizeSampleNeedRefresh = Notification.Name("SummarizeSampleNeedRefresh")
}

// 屏幕宽度
@MainActor
let SCREEN_WIDTH = UIScreen.main.bounds.size.width

// 屏幕高度
@MainActor
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

// 判断是否为 iPhone
@MainActor
let Is_Iphone = UIDevice.current.userInterfaceIdiom == .phone

// 判断是否为 iPhone X 系列
@MainActor
let Is_IPhoneX = SCREEN_WIDTH >= 375.0 && SCREEN_HEIGHT >= 812.0 && Is_Iphone

// 状态栏高度
@MainActor
let STATUS_BAR_HEIGHT = Is_IPhoneX ? 44.0 : 20.0

// TabBar 高度
@MainActor
let TABBAR_HEIGHT = Is_IPhoneX ? (49.0 + 34.0) : 49.0

// 导航栏高度
@MainActor
let NAV_HEIGHT = Is_IPhoneX ? 88 : 64

// 底部安全区域高度
@MainActor
let Bottom_SafeHeight = Is_IPhoneX ? 34.0 : 0

// 安全区域高度
@MainActor
var SafeAreaHeight: CGFloat {
    return MOAppDelegate().window?.safeAreaLayoutGuide.layoutFrame.size.height ?? 0
}

// 从代码获取状态栏高度（这里假设 statusBarFromCode 是 UIDevice 的一个类方法）
// 由于不清楚具体实现，这里简单返回 0
@MainActor func STATUS_BAR_Height_CODE() -> CGFloat {
    return UIDevice.statusBarFromCode()
}

// APP 版本号字符串
let APPVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let QQAppId = "1112354807"

func MOPingFangSCFont(_ fontSize:Float) ->UIFont {
    return UIFont.init(name: "PingFangSC-Regular", size: CGFloat(fontSize))!
}
func MOPingFangSCHeavyFont(_ fontSize:Float) ->UIFont {
    return UIFont.init(name: "PingFangSC-Medium", size: CGFloat(fontSize))!
}
func MOPingFangSCMediumFont(_ fontSize:Float) ->UIFont {
    return UIFont.init(name: "PingFangSC-Medium", size: CGFloat(fontSize))!
}
func MOPingFangSCBoldFont(_ fontSize:Float) ->UIFont {
    return UIFont.init(name: "PingFangSC-Semibold", size: CGFloat(fontSize))!
}

#if DEBUG
func DLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    print("\(fileName) \(function) [Line \(line)] \(message)")
}
#else
func DLog(_: String) {}
#endif
