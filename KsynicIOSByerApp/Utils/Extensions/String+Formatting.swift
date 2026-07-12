import Foundation

extension String {
    func normalizedDouble(allowBlank: Bool = false) -> Double? {
        if allowBlank && isEmpty { return nil }
        let normalized = self.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
    
    func maskedPhone() -> String {
        let digits = self.filter { $0.isNumber }
        guard digits.count >= 4 else { return self }
        let prefix = String(digits.prefix(2))
        let suffix = String(digits.suffix(2))
        return "\(prefix) *** ** \(suffix)"
    }
    
    func pluralizedReview(count: Int) -> String {
        let rem10 = count % 10
        let rem100 = count % 100
        if rem10 == 1 && rem100 != 11 {
            return "\(count) отзыв"
        } else if (2...4).contains(rem10) && !(12...14).contains(rem100) {
            return "\(count) отзыва"
        } else {
            return "\(count) отзывов"
        }
    }
}

func statusText(_ status: String?) -> String {
    switch status {
    case "draft": return "Черновик"
    case "published": return "В продаже"
    case "archived": return "Архив"
    case "pending": return "На проверке"
    case "active": return "Активен"
    default: return status?.ifEmpty("Статус") ?? "Статус"
    }
}

extension String {
    func ifEmpty(_ fallback: String) -> String {
        return isEmpty ? fallback : self
    }
}
