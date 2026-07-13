import SwiftUI

struct ProductRow: View {
    let product: SellerProductDto
    let onEdit: () -> Void
    let onTogglePublish: () -> Void
    let onArchive: () -> Void
    let onReviews: () -> Void
    let onDelete: () -> Void
    
    private var isPending: Bool { product.status == "pending" }
    private var statusLabel: String {
        isPending ? "Проходит модерацию" : statusText(product.status)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ProductImage(path: product.primaryImage, size: 64)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name ?? "Без названия")
                        .font(.sellerBody)
                        .fontWeight(.bold)
                        .foregroundColor(.sellerInk)
                    Text("Арт. \(product.article ?? "—") · \(product.category?.name ?? "—")")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                    Text((product.price).money())
                        .font(.sellerBody)
                        .fontWeight(.semibold)
                    StatusPill(text: statusLabel, color: .statusColor(product.status))
                }
                
                Spacer()
            }
            
            if let reviewsCount = product.reviewsCount, reviewsCount > 0 {
                Button(action: onReviews) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.sellerOrange)
                            .font(.caption)
                        Text("\(reviewsCount) отзывов")
                            .font(.sellerCaption)
                            .foregroundColor(.sellerMuted)
                    }
                }
            }
            
            HStack(spacing: 8) {
                Button("Редактирование") {
                    onEdit()
                }
                .buttonStyle(OutlineButtonStyle())
                .disabled(isPending)
                
                Button(product.status == "published" ? "Снять с публикации" : "Опубликовать") {
                    onTogglePublish()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isPending)
                
                Button(action: onArchive) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(IconButtonStyle())
                
                Button(action: onReviews) {
                    Image(systemName: "bubble.left")
                }
                .buttonStyle(IconButtonStyle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(IconButtonStyle())
            }
        }
        .padding(14)
        .background(Color.sellerSurface)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}


