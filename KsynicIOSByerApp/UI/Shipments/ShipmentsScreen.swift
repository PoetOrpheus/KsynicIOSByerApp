import SwiftUI

struct ShipmentsScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    let onClose: () -> Void
    
    @State private var selectedOrder: SellerOrderDto?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.dashboard?.toShip?.isEmpty != false {
                        EmptyPanel(text: "Нет заказов к отправке", systemImage: "box")
                            .padding(.horizontal, 16)
                    } else {
                        ForEach(viewModel.dashboard?.toShip ?? []) { order in
                            ShipmentCard(order: order, onShowQR: { selectedOrder = order })
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Ближайшие к отправке")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.sellerBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Назад") { onClose() }
                }
            }
        }
        .alert(item: $selectedOrder) { order in
            Alert(
                title: Text("QR-код для ПВЗ"),
                message: Text(order.title ?? "Заказ"),
                dismissButton: .default(Text("Закрыть"))
            )
        }
    }
}

struct ShipmentCard: View {
    let order: SellerOrderDto
    let onShowQR: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ProductImage(path: order.imageUrl, size: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.title ?? "Без названия")
                        .font(.sellerBody)
                        .fontWeight(.bold)
                    Text("Арт. \(order.article ?? "—")")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                    Text("Кол-во: \(order.quantity ?? 0)")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                    Text((order.price).money())
                        .font(.sellerBody)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            
            Divider()
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.red)
                Text("До: \(deadline(for: order))")
                    .font(.sellerBody)
                    .foregroundColor(.red)
                Spacer()
                Button("QR-код") { onShowQR() }
                    .buttonStyle(OutlineButtonStyle())
            }
        }
        .padding(14)
        .background(Color.sellerSurface)
        .cornerRadius(8)
    }
    
    private func deadline(for order: SellerOrderDto) -> String {
        let dateString = order.expectedDate ?? order.createdAt ?? ISO8601DateFormatter().string(from: Date())
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: dateString)
        if date == nil {
            let fallback = DateFormatter()
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            date = fallback.date(from: dateString)
        }
        guard let baseDate = date else { return "—" }
        let deadlineDate = baseDate.addingTimeInterval(72 * 3600)
        let out = DateFormatter()
        out.dateFormat = "d MMMM, HH:mm"
        out.locale = Locale(identifier: "ru_RU")
        return out.string(from: deadlineDate)
    }
}
