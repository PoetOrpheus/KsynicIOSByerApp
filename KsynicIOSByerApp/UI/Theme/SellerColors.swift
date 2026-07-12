import SwiftUI

extension Color {
    static let sellerBlack = Color(red: 0x05/255, green: 0x05/255, blue: 0x05/255)
    static let sellerWhite = Color.white
    static let sellerInk = Color(red: 0x15/255, green: 0x15/255, blue: 0x15/255)
    static let sellerMuted = Color(red: 0x74/255, green: 0x74/255, blue: 0x74/255)
    static let sellerCloud = Color(red: 0xF4/255, green: 0xF4/255, blue: 0xF4/255)
    static let sellerLine = Color(red: 0xE7/255, green: 0xE7/255, blue: 0xE7/255)
    static let sellerBlue = Color(red: 0x2E/255, green: 0x7D/255, blue: 0xBA/255)
    static let sellerBlueDark = Color(red: 0xB7/255, green: 0xD7/255, blue: 0xF5/255)
    static let sellerGreen = Color(red: 0x08/255, green: 0x7F/255, blue: 0x5B/255)
    static let sellerOrange = Color(red: 0xC8/255, green: 0x78/255, blue: 0x10/255)
    static let sellerBackground = Color.white
    static let sellerSurface = Color.white
    static let sellerSurfaceDark = Color(red: 0x17/255, green: 0x1A/255, blue: 0x1F/255)
    static let sellerBackgroundDark = Color(red: 0x0F/255, green: 0x12/255, blue: 0x17/255)
    
    static let authSecondary = Color(red: 0x4A/255, green: 0x4A/255, blue: 0x4A/255)
    static let authFieldLabel = Color(red: 0x3D/255, green: 0x3D/255, blue: 0x3D/255)
    static let authFieldBorder = Color(red: 0xB8/255, green: 0xB8/255, blue: 0xB8/255)
    
    static let statusDraft = Color(red: 0x8A/255, green: 0x5A/255, blue: 0x00/255)
}

extension Color {
    static func statusColor(_ status: String?) -> Color {
        switch status {
        case "published", "active":
            return .sellerBlack
        case "draft", "pending":
            return .statusDraft
        case "archived":
            return .sellerMuted
        default:
            return .sellerGreen
        }
    }
}
