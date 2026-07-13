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
                        .foregroundColor(.sellerInk)
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
        // Android logic: expected_date ?? created_at ?? current time, then +72 hours.
        let baseDate = parseDeadlineDate(order.expectedDate)
            ?? parseDeadlineDate(order.createdAt)
            ?? Date()
        let deadlineDate = baseDate.addingTimeInterval(72 * 3600)
        let out = DateFormatter()
        out.dateFormat = "d MMMM, HH:mm"
        out.locale = Locale(identifier: "ru_RU")
        return out.string(from: deadlineDate)
    }

    private func parseDeadlineDate(_ string: String?) -> Date? {
        guard let string = string, !string.isEmpty else { return nil }
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "UTC")
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
}
