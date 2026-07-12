import SwiftUI

struct ProductImage: View {
    let path: String?
    let size: CGFloat
    
    init(path: String?, size: CGFloat = 48) {
        self.path = path
        self.size = size
    }
    
    var body: some View {
        if let urlString = NetworkConfig.mediaUrl(path: path), let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            placeholder
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Color.sellerCloud
            Image(systemName: "photo")
                .foregroundColor(.sellerMuted)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
