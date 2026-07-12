import Foundation

struct SellerSession: Codable {
    var isLoggedIn: Bool = false
    var sellerId: String = ""
    var sellerProfileId: String = ""
    var shopName: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    var email: String = ""
    var description: String = ""
    var sellerStatus: String = ""
    var isActive: Bool = false
    var isSellerVerified: Bool = false
    var isPhoneVerified: Bool = false
    var isEmailVerified: Bool = false
    var pickupPointId: String = ""
    var pickupPoint: String = ""
    var documentsVerified: Bool = false
    var notificationsEnabled: Bool = true
    
    var displayName: String {
        let name = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
        if !name.isEmpty { return name }
        if !shopName.isEmpty { return shopName }
        if !phone.isEmpty { return phone }
        return email
    }
}

final class SellerSessionStore {
    static let shared = SellerSessionStore()
    
    private let defaults = UserDefaults.standard
    private let key = "seller_session"
    
    private init() {}
    
    func save(_ session: SellerSession) {
        if let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: key)
        }
    }
    
    func load() -> SellerSession {
        guard let data = defaults.data(forKey: key),
              let session = try? JSONDecoder().decode(SellerSession.self, from: data) else {
            return SellerSession()
        }
        return session
    }
    
    func clear() {
        defaults.removeObject(forKey: key)
    }
}
