import Foundation

extension KeyedDecodingContainer {
    func decodeDoubleOrString(forKey key: Key) -> Double? {
        if let value = try? decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            return Double(value)
        }
        return nil
    }
    
    func decodeIntOrString(forKey key: Key) -> Int? {
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            if let int = Int(value) {
                return int
            }
            return Int(Double(value) ?? 0)
        }
        return nil
    }
}
