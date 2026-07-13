import SwiftUI

struct SellerTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var isEnabled: Bool = true
    var minLines: Int = 1
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.sellerCaption)
                .foregroundColor(.authFieldLabel)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .disabled(!isEnabled)
                    .foregroundColor(.sellerInk)
                    .padding(12)
                    .background(Color.sellerSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.authFieldBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
            } else if minLines > 1 {
                TextEditor(text: $text)
                    .disabled(!isEnabled)
                    .foregroundColor(.sellerInk)
                    .frame(minHeight: CGFloat(minLines * 20))
                    .padding(8)
                    .background(Color.sellerSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.authFieldBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
            } else {
                TextField(placeholder, text: $text)
                    .disabled(!isEnabled)
                    .foregroundColor(.sellerInk)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit?()
                    }
                    .padding(12)
                    .background(Color.sellerSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.authFieldBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Готово") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .foregroundColor(.sellerBlue)
                }
            }
        }
    }
}
