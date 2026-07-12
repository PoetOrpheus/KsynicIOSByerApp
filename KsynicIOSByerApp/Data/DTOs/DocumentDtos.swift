import Foundation

struct SellerDocumentDto: Codable, Identifiable {
    var id: String { idValue ?? UUID().uuidString }
    private let idValue: String?
    let sellerId: String?
    let documentType: String?
    let documentName: String?
    let fileName: String?
    let fileUrl: String?
    let mimeType: String?
    let fileSize: Int64?
    let reviewStatus: String?
    let uploadedAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case sellerId = "seller_id"
        case documentType = "document_type"
        case documentName = "document_name"
        case fileName = "file_name"
        case fileUrl = "file_url"
        case mimeType = "mime_type"
        case fileSize = "file_size"
        case reviewStatus = "review_status"
        case uploadedAt = "uploaded_at"
        case updatedAt = "updated_at"
    }
}

struct UploadSellerDocumentRequest: Codable {
    let documentType: String
    let documentName: String
    let base64: String
    let mimeType: String?
    let fileName: String?
    
    enum CodingKeys: String, CodingKey {
        case documentType = "document_type"
        case documentName = "document_name"
        case base64
        case mimeType = "mime_type"
        case fileName = "file_name"
    }
}

struct SellerDocumentsResponse: Codable {
    let success: Bool?
    let data: [SellerDocumentDto]?
}

struct SellerDocumentResponse: Codable {
    let success: Bool?
    let message: String?
    let data: SellerDocumentDto?
}
