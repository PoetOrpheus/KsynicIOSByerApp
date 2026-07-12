import SwiftUI

struct EmptyPanel: View {
    let text: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(.sellerMuted)
            Text(text)
                .foregroundColor(.sellerMuted)
                .font(.sellerBody)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.sellerSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.sellerLine, lineWidth: 1)
        )
        .cornerRadius(8)
    }
}
