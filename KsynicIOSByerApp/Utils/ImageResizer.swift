import UIKit

enum ImageResizer {
    static func resize(image: UIImage, maxSide: CGFloat = 1200) -> UIImage? {
        let size = image.size
        let ratio = size.width / size.height
        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: min(size.width, maxSide), height: min(size.width, maxSide) / ratio)
        } else {
            newSize = CGSize(width: min(size.height, maxSide) * ratio, height: min(size.height, maxSide))
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    static func base64JPEG(image: UIImage, quality: CGFloat = 0.8) -> String? {
        guard let data = image.jpegData(compressionQuality: quality) else { return nil }
        return "data:image/jpeg;base64," + data.base64EncodedString()
    }
}
