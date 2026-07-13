import SwiftUI

struct ReviewsScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    
    @State private var selectedProductId: String = ""
    @State private var minRating: Int = 0
    @State private var onlyWithPhoto: Bool = false
    @State private var sortNewestFirst: Bool = true
    @State private var showFilters: Bool = false
    
    private var filteredReviews: [ProductReviewDto] {
        let items = viewModel.sellerReviews?.items ?? []
        return items.filter { review in
            if !selectedProductId.isEmpty, review.productId != selectedProductId { return false }
            if minRating > 0, (review.rating ?? 0) < minRating { return false }
            if onlyWithPhoto, review.hasPhoto != true { return false }
            return true
        }.sorted {
            sortNewestFirst ? ($0.createdAt ?? "") > ($1.createdAt ?? "") : ($0.createdAt ?? "") < ($1.createdAt ?? "")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            statsBlock
            
            HStack {
                Text("Отзывы покупателей")
                    .font(.sellerHeadline)
                Spacer()
                Button("Фильтры") { showFilters.toggle() }
                    .font(.sellerCaption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            if showFilters {
                filtersBlock
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    if filteredReviews.isEmpty {
                        EmptyPanel(text: "Отзывы не найдены", systemImage: "star")
                            .padding(.horizontal, 16)
                    } else {
                        ForEach(filteredReviews) { review in
                            ReviewCard(review: review)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .onAppear {
            Task { await viewModel.loadSellerReviews() }
            if let filter = viewModel.reviewsProductFilter {
                selectedProductId = filter
            }
        }
        .background(Color.sellerBackground)
    }
    
    private var statsBlock: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "%.1f", viewModel.sellerReviews?.averageRating ?? 0))
                    .font(.system(size: 40, weight: .bold))
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= Int(viewModel.sellerReviews?.averageRating ?? 0) ? "star.fill" : "star")
                            .foregroundColor(.sellerOrange)
                            .font(.caption)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                let total = viewModel.sellerReviews?.total ?? 0
                Text("".pluralizedReview(count: total))
                    .font(.sellerCaption)
                    .foregroundColor(.sellerMuted)
                if let distribution = viewModel.sellerReviews?.distribution {
                    ForEach((1...5).reversed(), id: \.self) { star in
                        HStack(spacing: 4) {
                            Text("\(star)")
                                .font(.caption)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.sellerCloud)
                                    let count = star <= distribution.count ? distribution[star - 1] : 0
                                    let width = total > 0 ? CGFloat(count) / CGFloat(total) * geo.size.width : 0
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.sellerOrange)
                                        .frame(width: width)
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color.sellerCloud)
    }
    
    private var filtersBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Товар", selection: $selectedProductId) {
                Text("Все товары").tag("")
                ForEach(viewModel.products) { product in
                    Text(product.name ?? "—").tag(product.id ?? "")
                }
            }
            .pickerStyle(.menu)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Все", isSelected: minRating == 0) { minRating = 0 }
                    ForEach(1...5, id: \.self) { rating in
                        FilterChip(title: "\(rating)★+", isSelected: minRating == rating) {
                            minRating = rating
                        }
                    }
                }
            }
            
            Toggle("Только с фото", isOn: $onlyWithPhoto)
            
            HStack(spacing: 8) {
                FilterChip(title: "Сначала новые", isSelected: sortNewestFirst) { sortNewestFirst = true }
                FilterChip(title: "Сначала старые", isSelected: !sortNewestFirst) { sortNewestFirst = false }
            }
        }
        .padding(12)
        .background(Color.sellerSurface)
        .cornerRadius(8)
    }
}

struct ReviewCard: View {
    let review: ProductReviewDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ProductImage(path: review.productImage, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.productName ?? "Товар")
                        .font(.sellerBody)
                        .fontWeight(.semibold)
                    Text(review.authorName ?? "Покупатель")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                }
                Spacer()
            }
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= (review.rating ?? 0) ? "star.fill" : "star")
                        .foregroundColor(.sellerOrange)
                        .font(.caption)
                }
            }
            
            if let text = review.text, !text.isEmpty {
                Text(text)
                    .font(.sellerBody)
                    .foregroundColor(.sellerInk)
            }
            
            if let images = review.images, !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                            ProductImage(path: image.imageUrl, size: 80)
                        }
                    }
                }
            }
            
            if let date = review.createdAt {
                Text(date)
                    .font(.sellerCaption)
                    .foregroundColor(.sellerMuted)
            }
        }
        .padding(14)
        .background(Color.sellerSurface)
        .cornerRadius(8)
    }
}
