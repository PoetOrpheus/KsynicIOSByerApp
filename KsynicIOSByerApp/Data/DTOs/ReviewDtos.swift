import Foundation

struct SellerReviewsPayloadDto: Codable {
    let total: Int?
    let new: Int?
    let averageRating: Double?
    let distribution: [Int]?
    let items: [ProductReviewDto]?
    
    enum CodingKeys: String, CodingKey {
        case total, new
        case averageRating = "average_rating"
        case distribution, items
    }
}

struct ProductReviewDto: Codable, Identifiable {
    var id: String { idValue ?? UUID().uuidString }
    private let idValue: String?
    let productId: String?
    let productName: String?
    let productImage: String?
    let authorName: String?
    let rating: Int?
    let text: String?
    let images: [String]?
    let createdAt: String?
    let hasPhoto: Bool?
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case productId = "product_id"
        case productName = "product_name"
        case productImage = "product_image"
        case authorName = "author_name"
        case rating, text, images
        case createdAt = "created_at"
        case hasPhoto = "has_photo"
    }
}

struct SellerReviewsResponse: Codable {
    let success: Bool?
    let data: SellerReviewsPayloadDto?
}

struct ProductReviewsResponse: Codable {
    let success: Bool?
    let data: [ProductReviewDto]?
}
