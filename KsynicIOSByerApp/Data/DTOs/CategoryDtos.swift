import Foundation

struct CategoryDto: Codable, Identifiable {
    let id: String
    let name: String?
    let slug: String?
    let parentId: String?
    let level: Int?
    let children: [CategoryDto]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case parentId = "parent_id"
        case level, children
    }
}

struct CategoryResponse: Codable {
    let success: Bool?
    let data: [CategoryDto]?
}

struct CategorySpecTemplateDto: Codable {
    let category: CategoryDto?
    let groups: [SpecificationGroupDto]?
}

struct CategorySpecTemplateResponse: Codable {
    let success: Bool?
    let data: CategorySpecTemplateDto?
}

struct SpecificationGroupDto: Codable {
    let title: String?
    let items: [SpecificationTemplateItemDto]?
}

struct SpecificationTemplateItemDto: Codable, Identifiable {
    var id: String { specKey ?? UUID().uuidString }
    let specKey: String?
    let label: String?
    let type: String?
    let scope: String?
    let required: Bool?
    let recommended: Bool?
    let hint: String?
    let placeholder: String?
    let unit: String?
    let options: [SpecificationOptionDto]?
    
    enum CodingKeys: String, CodingKey {
        case specKey = "spec_key"
        case label, type, scope, required, recommended, hint, placeholder, unit, options
    }
}

struct SpecificationOptionDto: Codable {
    let value: String?
    let label: String?
}
