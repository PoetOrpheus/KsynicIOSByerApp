import Foundation

enum NetworkConfig {
    static let apiBaseURL = "http://82.202.143.20/api"
    static let mediaBaseURL = "http://82.202.143.20"
    
    static let connectTimeout: TimeInterval = 15
    static let readTimeout: TimeInterval = 30
    static let writeTimeout: TimeInterval = 60
    
    static func mediaUrl(path: String?) -> String? {
        guard let raw = path?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else {
            return nil
        }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return raw
        }
        return mediaBaseURL + "/" + raw.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}
