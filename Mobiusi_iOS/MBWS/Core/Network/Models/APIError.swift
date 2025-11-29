import Foundation

// 确保APIError只声明一次，如果其他地方已有，请移除
enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError(String)
    case networkError(String)
    case noData
    case decodingError(String)
    case invalidResponse
    case businessError(String)
    case invalidToken(String)
    case loginRequired
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .encodingError(let message):
            return "参数编码错误: \(message)"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .noData:
            return "没有返回数据"
        case .decodingError(let message):
            return "数据解析错误: \(message)"
        case .invalidResponse:
            return "无效的响应"
        case .businessError(let message):
            return message
        case .invalidToken(let message):
            return message
        case .loginRequired:
            return "需要重新登录"
        }
    }
}
