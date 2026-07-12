import SwiftUI

struct DashboardScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    let onOpenShipments: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statusPanel
                readinessBlock
                reviewsBlock
                metricsSection
                ordersSection
            }
            .padding(16)
        }
        .refreshable {
            await viewModel.refreshAll()
        }
        .onAppear {
            Task {
                await viewModel.refreshDashboard()
                await viewModel.loadSellerReviews()
            }
        }
    }
    
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ожидают поступления")
                .font(.sellerCaption)
                .foregroundColor(.white.opacity(0.8))
            Text((viewModel.analytics?.frozenFunds14d).money())
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sellerBlack)
        .cornerRadius(28)
    }
    
    private var readinessBlock: some View {
        FormCard(title: "Готовность кабинета") {
            VStack(alignment: .leading, spacing: 12) {
                readinessRow(icon: "checkmark.circle.fill", text: "Кабинет активен", isOk: viewModel.session.isActive)
                readinessRow(icon: "location.circle.fill", text: viewModel.session.pickupPointId.isEmpty ? "ПВЗ не выбран" : (viewModel.session.pickupPoint.ifEmpty("ПВЗ выбран")), isOk: !viewModel.session.pickupPointId.isEmpty)
                readinessRow(icon: "doc.text.fill", text: viewModel.session.documentsVerified ? "Документы проверены" : "Документы не проверены", isOk: viewModel.session.documentsVerified)
                
                if !viewModel.canCreateProduct {
                    HStack(spacing: 12) {
                        Button("Указать ПВЗ") {
                            // Navigate to profile handled externally or via notification
                        }
                        .buttonStyle(SmallButtonStyle())
                        
                        Button("Отправить документы") {
                            // Navigate to documents
                        }
                        .buttonStyle(SmallButtonStyle())
                    }
                }
            }
        }
    }
    
    private func readinessRow(icon: String, text: String, isOk: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(isOk ? .sellerGreen : .sellerOrange)
            Text(text)
                .font(.sellerBody)
                .foregroundColor(.sellerInk)
            Spacer()
        }
    }
    
    private var reviewsBlock: some View {
        FormCard(title: "Отзывы") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    let total = viewModel.sellerReviews?.total ?? 0
                    Text("".pluralizedReview(count: total))
                        .font(.sellerHeadline)
                    if let rating = viewModel.sellerReviews?.averageRating, rating > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.sellerOrange)
                            Text(String(format: "%.1f", rating))
                                .font(.sellerBody)
                        }
                    }
                    if let new = viewModel.sellerReviews?.new, new > 0 {
                        Text("\(new) новых за неделю")
                            .font(.sellerCaption)
                            .foregroundColor(.sellerMuted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.sellerMuted)
            }
        }
    }
    
    private var metricsSection: some View {
        FormCard(title: "Статистика") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricCard(title: "Всего товаров", value: "\(viewModel.session.isLoggedIn ? viewModel.products.count : 0)")
                metricCard(title: "Активные", value: "\(viewModel.products.filter { $0.status == "published" }.count)")
                metricCard(title: "Доход за месяц", value: (viewModel.analytics?.incomeThisMonth).money())
                metricCard(title: "Расходы за месяц", value: (viewModel.analytics?.expensesThisMonth).money())
            }
        }
    }
    
    private func metricCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.sellerCaption)
                .foregroundColor(.sellerMuted)
            Text(value)
                .font(.sellerHeadline)
                .foregroundColor(.sellerInk)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sellerCloud)
        .cornerRadius(8)
    }
    
    private var ordersSection: some View {
        FormCard(title: "Заказы") {
            VStack(spacing: 12) {
                Button(action: onOpenShipments) {
                    HStack {
                        Image(systemName: "archivebox")
                            .foregroundColor(.sellerInk)
                        VStack(alignment: .leading) {
                            Text("Ближайшие к отправке")
                                .font(.sellerBody)
                                .foregroundColor(.sellerInk)
                        }
                        Spacer()
                        Text("\(viewModel.dashboard?.toShip?.count ?? 0)")
                            .font(.sellerLabel)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.sellerOrange.opacity(0.12))
                            .foregroundColor(.sellerOrange)
                            .cornerRadius(8)
                    }
                    .padding(12)
                    .background(Color.sellerCloud)
                    .cornerRadius(8)
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    orderCard(title: "Ждут оплату", value: "\(viewModel.analytics?.sentUnpaidOrders ?? 0)", icon: "wallet.pass")
                    orderCard(title: "Отправлены", value: "\(viewModel.dashboard?.sent?.count ?? 0)", icon: "shippingbox")
                    orderCard(title: "Возвраты", value: "\(viewModel.dashboard?.returns?.count ?? 0)", icon: "return")
                    orderCard(title: "Всего заказов", value: "\(viewModel.analytics?.ordersThisMonth ?? 0)", icon: "doc.text")
                }
            }
        }
    }
    
    private func orderCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.sellerMuted)
            Text(value)
                .font(.sellerHeadline)
            Text(title)
                .font(.sellerCaption)
                .foregroundColor(.sellerMuted)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.sellerCloud)
        .cornerRadius(8)
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
