import SwiftUI

struct FormCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: title)
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sellerSurface)
        .cornerRadius(8)
    }
}
