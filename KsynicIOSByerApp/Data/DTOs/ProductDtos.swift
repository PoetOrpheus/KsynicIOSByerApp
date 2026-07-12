import Foundation

struct SellerProductDto: Codable, Identifiable {
    var id: String { idValue ?? UUID().uuidString }
    private let idValue: String?
    let article: String?
    let sellerId: String?
    let name: String?
    let slug: String?
    let description: String?
    let shortDescription: String?
    let price: Double?
    let oldPrice: Double?
    let discountPercent: Int?
    let categoryId: String?
    let stockQuantity: Int?
    let isUnlimitedStock: Bool?
    let status: String?
    let isActive: Bool?
    let rating: Double?
    let ratingsCount: Int?
    let reviewsCount: Int?
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?
    let category: ProductCategoryDto?
    let primaryImage: String?
    let primaryThumbnail: String?
    let images: [ProductImageDto]?
    let specifications: [SellerProductSpecDto]?
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case article
        case sellerId = "seller_id"
        case name, slug, description
        case shortDescription = "short_description"
        case price
        case oldPrice = "old_price"
        case discountPercent = "discount_percent"
        case categoryId = "category_id"
        case stockQuantity = "stock_quantity"
        case isUnlimitedStock = "is_unlimited_stock"
        case status
        case isActive = "is_active"
        case rating
        case ratingsCount = "ratings_count"
        case reviewsCount = "reviews_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case category
        case primaryImage = "primary_image"
        case primaryThumbnail = "primary_thumbnail"
        case images, specifications
    }
}

struct ProductCategoryDto: Codable, Identifiable {
    let id: String?
    let name: String?
    let slug: String?
    let parentId: String?
    let level: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case parentId = "parent_id"
        case level
    }
}

struct ProductImageDto: Codable, Identifiable {
    let id: String?
    let imageUrl: String?
    let thumbnailUrl: String?
    let altText: String?
    let sortOrder: Int?
    let isPrimary: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case altText = "alt_text"
        case sortOrder = "sort_order"
        case isPrimary = "is_primary"
    }
}

struct SellerProductSpecDto: Codable, Identifiable {
    let id: String?
    let specKey: String?
    let specValue: String?
    let value: String?
    let label: String?
    let type: String?
    let scope: String?
    let unit: String?
    let group: String?
    let sortOrder: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case specKey = "spec_key"
        case specValue = "spec_value"
        case value, label, type, scope, unit, group
        case sortOrder = "sort_order"
    }
}

struct UpsertSellerProductRequest: Codable {
    let name: String
    let price: Double
    let oldPrice: Double?
    let categoryId: String
    let stockQuantity: Int?
    let isUnlimitedStock: Bool?
    let status: String
    let description: String?
    let shortDescription: String?
    let images: [ProductImageInputDto]?
    let specifications: [ProductSpecInputDto]
    
    enum CodingKeys: String, CodingKey {
        case name, price
        case oldPrice = "old_price"
        case categoryId = "category_id"
        case stockQuantity = "stock_quantity"
        case isUnlimitedStock = "is_unlimited_stock"
        case status, description
        case shortDescription = "short_description"
        case images, specifications
    }
}

struct ProductImageInputDto: Codable {
    let imageUrl: String?
    let thumbnailUrl: String?
    let base64: String?
    let altText: String?
    let isPrimary: Bool?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case thumbnailUrl = "thumbnail_url"
        case base64
        case altText = "alt_text"
        case isPrimary = "is_primary"
    }
}

struct ProductSpecInputDto: Codable {
    let specKey: String
    let specValue: String
    
    enum CodingKeys: String, CodingKey {
        case specKey = "spec_key"
        case specValue = "spec_value"
    }
}

struct ProductStatusRequest: Codable {
    let status: String
}

struct SellerProductsResponse: Codable {
    let success: Bool?
    let data: [SellerProductDto]?
    let total: Int?
    let page: Int?
    let limit: Int?
}

struct SellerProductResponse: Codable {
    let success: Bool?
    let data: SellerProductDto?
}
