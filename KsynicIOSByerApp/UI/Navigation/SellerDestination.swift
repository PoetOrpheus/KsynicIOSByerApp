import SwiftUI

enum SellerDestination: String, CaseIterable {
    case dashboard = "Сводка"
    case products = "Товары"
    case create = "Создать"
    case documents = "Документы"
    case reviews = "Отзывы"
    case profile = "Профиль"
    
    var icon: String {
        switch self {
        case .dashboard: return "house"
        case .products: return "list.bullet"
        case .create: return "plus"
        case .documents: return "doc.text"
        case .reviews: return "bubble.left"
        case .profile: return "person"
        }
    }
}
