import SwiftUI
import UIKit

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
    }
}

// MARK: - Numeric / phone-pad field with a native Done toolbar

/// A numeric field backed by UIKit so the Done toolbar is guaranteed to show
/// on .phonePad / .numberPad / .decimalPad keyboards.
struct SellerNumericField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .numberPad
    var textColor: Color = .sellerInk
    var surfaceColor: Color = .sellerSurface
    var onDone: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.sellerCaption)
                .foregroundColor(.authFieldLabel)
            
            NumericTextField(text: $text, placeholder: placeholder, keyboardType: keyboardType, textColor: textColor, onDone: onDone)
                .frame(height: 44)
                .padding(.horizontal, 12)
                .background(surfaceColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.authFieldBorder, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

private struct NumericTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var textColor: Color
    var onDone: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = keyboardType
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = UIColor(textColor)
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.delegate = context.coordinator
        textField.inputAccessoryView = makeToolbar(coordinator: context.coordinator)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func makeToolbar(coordinator: Coordinator) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.items = [flexSpace, doneButton]
        return toolbar
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NumericTextField
        
        init(_ parent: NumericTextField) {
            self.parent = parent
        }
        
        @objc func doneTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            parent.onDone?()
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            parent.text = updatedText
            return true
        }
    }
}
