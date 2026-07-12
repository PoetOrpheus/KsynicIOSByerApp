import SwiftUI

struct ErrorText: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(text)
                .font(.sellerBody)
            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .foregroundColor(.red)
        .cornerRadius(8)
    }
}
