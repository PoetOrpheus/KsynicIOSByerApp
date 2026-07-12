import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.sellerBlack)
            .cornerRadius(26)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sellerCaption)
            .fontWeight(.semibold)
            .foregroundColor(.sellerInk)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.sellerLine, lineWidth: 1)
            )
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.sellerMuted)
            .padding(8)
            .background(Color.sellerCloud)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SmallButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sellerCaption)
            .fontWeight(.semibold)
            .foregroundColor(.sellerInk)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.sellerCloud)
            .cornerRadius(8)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.sellerCaption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .sellerInk)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.sellerBlack : Color.sellerCloud)
                .cornerRadius(16)
        }
    }
}
