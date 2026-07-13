import SwiftUI

struct ProductsScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    @State private var showDeleteConfirmation: SellerProductDto?
    
    let filters: [(String?, String)] = [
        (nil, "Все"),
        ("draft", "Черновики"),
        ("published", "Опубликованы"),
        ("archived", "Архив")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.0) { status, title in
                            FilterChip(
                                title: title,
                                isSelected: viewModel.productsStatusFilter == status
                            ) {
                                viewModel.productsStatusFilter = status
                                Task { await viewModel.loadProducts(status: status) }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                if viewModel.products.isEmpty {
                    EmptyPanel(text: "Товары не найдены", systemImage: "info.circle")
                        .padding(.horizontal, 16)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.products) { product in
                            ProductRow(
                                product: product,
                                onEdit: {
                                    Task { await viewModel.beginProductEdit(id: product.id ?? "") }
                                },
                                onTogglePublish: {
                                    if product.status == "published" {
                                        Task { await viewModel.updateProductStatus(id: product.id ?? "", status: "archived") }
                                    } else {
                                        Task { await viewModel.requestProductPublication(id: product.id ?? "") }
                                    }
                                },
                                onArchive: {
                                    Task { await viewModel.updateProductStatus(id: product.id ?? "", status: "archived") }
                                },
                                onReviews: {
                                    viewModel.reviewsProductFilter = product.id
                                    // Switch to reviews tab would need external coordination
                                },
                                onDelete: {
                                    showDeleteConfirmation = product
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.loadProducts(status: viewModel.productsStatusFilter)
        }
        .onAppear {
            Task { await viewModel.loadProducts(status: viewModel.productsStatusFilter) }
        }
        .alert(item: $showDeleteConfirmation) { product in
            Alert(
                title: Text("Удалить товар?"),
                message: Text(product.name ?? "Без названия"),
                primaryButton: .destructive(Text("Удалить")) {
                    Task { await viewModel.deleteProduct(id: product.id ?? "") }
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }
}

