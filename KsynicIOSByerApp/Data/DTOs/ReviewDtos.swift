import Foundation

struct SellerReviewsPayloadDto: Codable {
    let totalReviews: Int?
    let newReviews: Int?
    let averageRating: Double?
    let reviews: [ProductReviewDto]?
    
    enum CodingKeys: String, CodingKey {
        case totalReviews = "total_reviews"
        case newReviews = "new_reviews"
        case averageRating = "average_rating"
        case reviews
    }
    
    // Backward-compatible helpers used by the UI
    var total: Int? { totalReviews }
    var new: Int? { newReviews }
    var items: [ProductReviewDto]? { reviews }
    var distribution: [Int]? { nil }
}

struct ReviewAuthorDto: Codable {
    let id: String?
    let displayName: String?
    let firstName: String?
    let lastName: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarUrl = "avatar_url"
    }
}

struct ReviewImageDto: Codable {
    let id: String?
    let imageUrl: String?
    let thumbnailUrl: String?
    let altText: String?
    let sortOrder: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case altText = "alt_text"
        case sortOrder = "sort_order"
    }
}

struct ProductReviewDto: Codable, Identifiable {
    var id: String { idValue ?? UUID().uuidString }
    private let idValue: String?
    let productId: String?
    let productName: String?
    let productRating: Int?
    let productReviewsCount: Int?
    let userId: String?
    let author: ReviewAuthorDto?
    let text: String?
    let likesCount: Int?
    let dislikesCount: Int?
    let images: [ReviewImageDto]?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case productId = "product_id"
        case productName = "product_name"
        case productRating = "product_rating"
        case productReviewsCount = "product_reviews_count"
        case userId = "user_id"
        case author, text
        case likesCount = "likes_count"
        case dislikesCount = "dislikes_count"
        case images
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idValue = try container.decodeIfPresent(String.self, forKey: .idValue)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        productRating = container.decodeIntOrString(forKey: .productRating)
        productReviewsCount = try container.decodeIfPresent(Int.self, forKey: .productReviewsCount)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        author = try container.decodeIfPresent(ReviewAuthorDto.self, forKey: .author)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        likesCount = try container.decodeIfPresent(Int.self, forKey: .likesCount)
        dislikesCount = try container.decodeIfPresent(Int.self, forKey: .dislikesCount)
        images = try container.decodeIfPresent([ReviewImageDto].self, forKey: .images)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    // Backward-compatible helpers used by the UI
    var authorName: String? {
        if let displayName = author?.displayName, !displayName.isEmpty {
            return displayName
        }
        let first = author?.firstName ?? ""
        let last = author?.lastName ?? ""
        let name = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Покупатель" : name
    }
    
    var rating: Int? { productRating }
    var productImage: String? { nil }
    var hasPhoto: Bool { !(images?.isEmpty ?? true) }
}

struct SellerReviewsResponse: Codable {
    let success: Bool?
    let data: SellerReviewsPayloadDto?
}

struct ProductReviewsResponse: Codable {
    let success: Bool?
    let data: [ProductReviewDto]?
}
