import Foundation


final class AlipayManager: NSObject, @unchecked Sendable {
    static let shared = AlipayManager()
    private let appId = "2021000122665324"
    private let universalLink = "https://www.mobiwusi.com"

     private override init() {
        super.init()
        // WXApi.registerApp(appId, universalLink: universalLink)
    }
}
