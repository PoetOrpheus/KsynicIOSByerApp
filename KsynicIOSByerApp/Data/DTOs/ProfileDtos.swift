import Foundation

struct SellerDetailsResponse: Codable {
    let success: Bool?
    let data: SellerProfileDto?
}

struct SellerProfileDto: Codable {
    let id: String?
    let sellerId: String?
    let sellerProfileId: String?
    let shopName: String?
    let description: String?
    let businessType: String?
    let legalName: String?
    let taxId: String?
    let registrationNumber: String?
    let sellerStatus: String?
    let sellerIsVerified: Bool?
    let documentsVerified: Bool?
    let notificationsEnabled: Bool?
    let sellerIsActive: Bool?
    let email: String?
    let phone: String?
    let firstName: String?
    let lastName: String?
    let displayName: String?
    let avatarUrl: String?
    let isEmailVerified: Bool?
    let isPhoneVerified: Bool?
    let totalProducts: Int?
    let publishedProducts: Int?
    let draftProducts: Int?
    let archivedProducts: Int?
    let pickupPointId: String?
    let pickupPoint: String?
    let pickupPointName: String?
    let pickupPointCity: String?
    let pickupPointAddress: String?
    let documents: [SellerDocumentDto]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sellerId = "seller_id"
        case sellerProfileId = "seller_profile_id"
        case shopName = "shop_name"
        case description
        case businessType = "business_type"
        case legalName = "legal_name"
        case taxId = "tax_id"
        case registrationNumber = "registration_number"
        case sellerStatus = "seller_status"
        case sellerIsVerified = "seller_is_verified"
        case documentsVerified = "documents_verified"
        case notificationsEnabled = "notifications_enabled"
        case sellerIsActive = "seller_is_active"
        case email, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case isEmailVerified = "is_email_verified"
        case isPhoneVerified = "is_phone_verified"
        case totalProducts = "total_products"
        case publishedProducts = "published_products"
        case draftProducts = "draft_products"
        case archivedProducts = "archived_products"
        case pickupPointId = "pickup_point_id"
        case pickupPoint = "pickup_point"
        case pickupPointName = "pickup_point_name"
        case pickupPointCity = "pickup_point_city"
        case pickupPointAddress = "pickup_point_address"
        case documents
    }
}

struct UpdateSellerRequest: Codable {
    let shopName: String? = nil
    let description: String? = nil
    let firstName: String? = nil
    let lastName: String? = nil
    let phone: String? = nil
    let email: String? = nil
    let avatarUrl: String? = nil
    let businessType: String? = nil
    let legalName: String? = nil
    let taxId: String? = nil
    let registrationNumber: String? = nil
    let pickupPointId: String? = nil
    let pickupPoint: String? = nil
    let notificationsEnabled: Bool? = nil
    
    enum CodingKeys: String, CodingKey {
        case shopName = "shop_name"
        case description
        case firstName = "first_name"
        case lastName = "last_name"
        case phone, email
        case avatarUrl = "avatar_url"
        case businessType = "business_type"
        case legalName = "legal_name"
        case taxId = "tax_id"
        case registrationNumber = "registration_number"
        case pickupPointId = "pickup_point_id"
        case pickupPoint = "pickup_point"
        case notificationsEnabled = "notifications_enabled"
    }
}
