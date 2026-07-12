import SwiftUI
import CoreImage.CIFilterBuiltins

struct QrCodeImage: View {
    let content: String
    let size: CGFloat
    
    init(content: String, size: CGFloat = 200) {
        self.content = content
        self.size = size
    }
    
    var body: some View {
        Image(uiImage: generateQRCode(from: content))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: size, height: size)
    }
    
    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage()
    }
}
