import SwiftUI

struct SellerTabView: View {
    @Binding var selected: SellerDestination
    let createEnabled: Bool
    let onCreateBlocked: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(SellerDestination.allCases, id: \.self) { destination in
                    tabButton(for: destination)
                }
            }
            .padding(4)
        }
        .background(
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.sellerCloud)
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .stroke(Color.sellerLine, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .frame(height: 64)
    }
    
    private func tabButton(for destination: SellerDestination) -> some View {
        let isSelected = selected == destination
        let isCreate = destination == .create
        let disabled = isCreate && !createEnabled
        
        return Button(action: {
            if disabled {
                onCreateBlocked()
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selected = destination
                }
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: destination.icon)
                Text(destination.rawValue)
                    .font(.sellerCaption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : (disabled ? .gray : Color(white: 0.33)))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(isSelected ? Color.sellerBlack : Color.clear)
            )
        }
        .disabled(disabled)
    }
}
