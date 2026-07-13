import Foundation

struct SellerDashboardDto: Codable {
    let toShip: [SellerOrderDto]?
    let sent: [SellerOrderDto]?
    let returns: [SellerOrderDto]?
    
    enum CodingKeys: String, CodingKey {
        case toShip = "to_ship"
        case sent, returns
    }
}

struct SellerDashboardResponse: Codable {
    let success: Bool?
    let data: SellerDashboardDto?
}

struct SellerOrderDto: Codable, Identifiable {
    var id: String { idValue ?? UUID().uuidString }
    private let idValue: String?
    let productId: String?
    let title: String?
    let quantity: Int?
    let status: String?
    let expectedDate: String?
    let pickupPoint: String?
    let imageUrl: String?
    let createdAt: String?
    let article: String?
    let price: Double?
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case productId = "product_id"
        case title, quantity, status
        case expectedDate = "expected_date"
        case pickupPoint = "pickup_point"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case article, price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idValue = try container.decodeIfPresent(String.self, forKey: .idValue)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        expectedDate = try container.decodeIfPresent(String.self, forKey: .expectedDate)
        pickupPoint = try container.decodeIfPresent(String.self, forKey: .pickupPoint)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        article = try container.decodeIfPresent(String.self, forKey: .article)
        price = container.decodeDoubleOrString(forKey: .price)
    }
}

struct SellerAnalyticsDto: Codable {
    let income: Double?
    let expenses: Double?
    let upcomingIncome: Double?
    let upcomingExpenses: Double?
    let penaltiesDue: Double?
    let frozenFunds14d: Double?
    let incomeThisMonth: Double?
    let expensesThisMonth: Double?
    let ordersThisMonth: Int?
    let toShipOrders: Int?
    let sentUnpaidOrders: Int?
    
    enum CodingKeys: String, CodingKey {
        case income, expenses
        case upcomingIncome = "upcoming_income"
        case upcomingExpenses = "upcoming_expenses"
        case penaltiesDue = "penalties_due"
        case frozenFunds14d = "frozen_funds_14d"
        case incomeThisMonth = "income_this_month"
        case expensesThisMonth = "expenses_this_month"
        case ordersThisMonth = "orders_this_month"
        case toShipOrders = "to_ship_orders"
        case sentUnpaidOrders = "sent_unpaid_orders"
    }
}

struct SellerAnalyticsResponse: Codable {
    let success: Bool?
    let data: SellerAnalyticsDto?
}

struct PickupPointDto: Codable, Identifiable {
    var id: String { idValue ?? UUID().uuidString }
    private let idValue: String?
    let name: String?
    let city: String?
    let address: String?
    let fullAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case idValue = "id"
        case name, city, address
        case fullAddress = "full_address"
    }
}

struct PickupPointsResponse: Codable {
    let success: Bool?
    let data: [PickupPointDto]?
}
