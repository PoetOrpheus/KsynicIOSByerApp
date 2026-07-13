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
    var textColor: Color = .sellerInk
    var surfaceColor: Color = .sellerSurface
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.sellerCaption)
                .foregroundColor(.authFieldLabel)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .disabled(!isEnabled)
                    .foregroundColor(textColor)
                    .padding(12)
                    .background(surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.authFieldBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
            } else if minLines > 1 {
                TextEditor(text: $text)
                    .disabled(!isEnabled)
                    .foregroundColor(textColor)
                    .frame(minHeight: CGFloat(minLines * 20))
                    .padding(8)
                    .background(surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.authFieldBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
            } else {
                TextField(placeholder, text: $text)
                    .disabled(!isEnabled)
                    .foregroundColor(textColor)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        onSubmit?()
                    }
                    .padding(12)
                    .background(surfaceColor)
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
                        if let action = onSubmit {
                            action()
                        } else {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                    .foregroundColor(.sellerBlue)
                }
            }
        }
    }
}

extension View {
    /// Adds a "Готово" / Done button above the software keyboard to dismiss it.
    /// Use on screens that contain numeric/phone-pad fields but no per-field submit action.
    func keyboardDoneButton(color: Color = .sellerBlue) -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Готово") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
                .foregroundColor(color)
            }
        }
    }
}
