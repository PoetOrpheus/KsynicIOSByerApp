import SwiftUI

struct SellerShell: View {
    @ObservedObject var viewModel: SellerViewModel
    @State private var selectedTab: SellerDestination = .dashboard
    @State private var showShipments: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topBar
                
                ZStack {
                    switch selectedTab {
                    case .dashboard:
                        DashboardScreen(viewModel: viewModel, onOpenShipments: { showShipments = true }, onOpenReviews: { selectedTab = .reviews })
                    case .products:
                        ProductsScreen(viewModel: viewModel)
                    case .create:
                        CreateProductScreen(viewModel: viewModel, onCreated: { selectedTab = .products })
                    case .documents:
                        DocumentsScreen(viewModel: viewModel)
                    case .reviews:
                        ReviewsScreen(viewModel: viewModel)
                    case .profile:
                        ProfileScreen(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                SellerTabView(
                    selected: $selectedTab,
                    createEnabled: viewModel.canCreateProduct,
                    onCreateBlocked: {
                        viewModel.setError(viewModel.canCreateProductReason() ?? "Создание товара недоступно")
                    }
                )
            }
            
            if viewModel.isBusy {
                VStack {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .sellerInk))
                        Text("Синхронизация")
                            .font(.sellerCaption)
                            .foregroundColor(.sellerInk)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.sellerCloud)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Spacer()
                }
                .padding(.top, 8)
            }
            
            if showShipments {
                ShipmentsScreen(viewModel: viewModel, onClose: { showShipments = false })
                    .transition(.move(edge: .bottom))
            }
        }
        .overlay(
            MessageOverlay(viewModel: viewModel)
                .padding(.top, 8),
            alignment: .top
        )
        .preferredColorScheme(.dark)
    }
    
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTab.rawValue)
                    .font(.sellerTitle)
                    .foregroundColor(.sellerInk)
                Text(viewModel.session.shopName.isEmpty ? "Ksynic Seller" : viewModel.session.shopName)
                    .font(.sellerCaption)
                    .foregroundColor(.sellerMuted)
            }
            Spacer()
            Button(action: { viewModel.logout() }) {
                Image(systemName: "arrowshape.turn.up.left")
                    .foregroundColor(.sellerInk)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.sellerBackground)
    }
}

struct MessageOverlay: View {
    @ObservedObject var viewModel: SellerViewModel
    
    var body: some View {
        VStack {
            if let error = viewModel.errorMessage, !error.isEmpty {
                ErrorText(text: error)
                    .onTapGesture { viewModel.clearMessages() }
            } else if let notice = viewModel.noticeMessage, !notice.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                    Text(notice)
                        .font(.sellerBody)
                    Spacer()
                }
                .padding(12)
                .background(Color.sellerGreen.opacity(0.1))
                .foregroundColor(.sellerGreen)
                .cornerRadius(8)
                .onTapGesture { viewModel.clearMessages() }
            }
        }
        .padding(.horizontal, 16)
    }
}
