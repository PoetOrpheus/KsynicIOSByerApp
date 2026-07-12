import Foundation

struct ApiMessageResponse: Codable {
    let success: Bool?
    let message: String?
    let error: String?
}

struct SellerRegisterRequest: Codable {
    let email: String
    let phone: String
    let password: String
    let firstName: String?
    let lastName: String?
    let shopName: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case email, phone, password
        case firstName = "first_name"
        case lastName = "last_name"
        case shopName = "shop_name"
        case description
    }
}

struct SellerLoginRequest: Codable {
    let email: String
    let phone: String
    let password: String
}

struct SellerAuthResponse: Codable {
    let success: Bool?
    let message: String?
    let data: SellerAuthPayloadDto?
}

struct SellerAuthPayloadDto: Codable {
    let seller: SellerAccountDto?
    let user: SellerUserDto?
}

struct SellerAccountDto: Codable {
    let id: String?
    let userId: String?
    let shopName: String?
    let description: String?
    let status: String?
    let isVerified: Bool?
    let documentsVerified: Bool?
    let notificationsEnabled: Bool?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case shopName = "shop_name"
        case description, status
        case isVerified = "is_verified"
        case documentsVerified = "documents_verified"
        case notificationsEnabled = "notifications_enabled"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SellerUserDto: Codable {
    let id: String?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let email: String?
    let displayName: String?
    let avatarUrl: String?
    let isEmailVerified: Bool?
    let isPhoneVerified: Bool?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case phone, email
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case isEmailVerified = "is_email_verified"
        case isPhoneVerified = "is_phone_verified"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SellerLookupRequest: Codable {
    let phone: String
}

struct SellerLookupResponse: Codable {
    let success: Bool?
    let exists: Bool?
    let message: String?
    let sellerId: String?
    let shopName: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case success, exists, message
        case sellerId = "seller_id"
        case shopName = "shop_name"
        case email
    }
}

struct VerifyPasswordRequest: Codable {
    let password: String
}

struct PhoneChangeRequest: Codable {
    let phone: String
}

struct PhoneChangeConfirmRequest: Codable {
    let phone: String
    let code: String
}

struct ContactVerificationRequest: Codable {
    let channel: String // phone | email
    let method: String? // sms | call
}

struct ContactVerificationConfirmRequest: Codable {
    let channel: String
    let code: String
}

struct ContactVerificationResponse: Codable {
    let success: Bool?
    let message: String?
    let data: ContactVerificationDto?
}

struct ContactVerificationDto: Codable {
    let channel: String?
    let target: String?
    let expiresAt: String?
    let debugCode: String?
    
    enum CodingKeys: String, CodingKey {
        case channel, target
        case expiresAt = "expires_at"
        case debugCode = "debug_code"
    }
}

struct VerificationRequestResponse: Codable {
    let success: Bool?
    let message: String?
    let status: String?
}
