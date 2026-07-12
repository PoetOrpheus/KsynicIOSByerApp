import Foundation

extension Double {
    func money() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: self)) ?? "0 ₽"
    }
}

extension Optional where Wrapped == Double {
    func money() -> String {
        return self?.money() ?? "0 ₽"
    }
}
