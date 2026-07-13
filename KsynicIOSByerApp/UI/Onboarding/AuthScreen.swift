import SwiftUI

struct AuthScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    @State private var selectedTab: Int = 0
    
    @State private var phone: String = "+7"
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var loginPassword: String = ""
    @State private var loginCode: String = ""
    @State private var registrationCode: String = ""
    @State private var passwordVisible: Bool = false
    
    var body: some View {
        ZStack {
            Color.sellerBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView {
                    VStack(spacing: 20) {
                        authModeSwitch
                        titleBlock
                        formContent
                        primaryButton
                        if let debugCode = viewModel.lastVerificationCode?.debugCode {
                            Text("Тестовый код: \(debugCode)")
                                .font(.sellerCaption)
                                .foregroundColor(.sellerMuted)
                        }
                    }
                    .padding(24)
                }
                .background(
                    Color.white
                        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 40)
            Text("Ksynic Seller")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
            Text("Кабинет продавца маркетплейса")
                .font(.sellerBody)
                .foregroundColor(.white.opacity(0.68))
            Spacer().frame(height: 30)
        }
        .frame(height: 220)
    }
    
    private var authModeSwitch: some View {
        HStack(spacing: 4) {
            modeButton(title: "Вход", index: 0)
            modeButton(title: "Регистрация", index: 1)
        }
        .padding(4)
        .background(Color.sellerCloud)
        .cornerRadius(8)
    }
    
    private func modeButton(title: String, index: Int) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = index
                viewModel.phoneLoginStep = .phone
                viewModel.registrationStep = .form
            }
        }) {
            Text(title)
                .font(.sellerBody)
                .fontWeight(selectedTab == index ? .semibold : .regular)
                .foregroundColor(selectedTab == index ? .sellerInk : .sellerMuted)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedTab == index ? Color.white : Color.clear)
                .cornerRadius(6)
        }
    }
    
    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text(titleText)
                .font(.sellerTitle)
                .foregroundColor(.sellerInk)
            Text(subtitleText)
                .font(.sellerBody)
                .foregroundColor(.authSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var titleText: String {
        if selectedTab == 0 {
            switch viewModel.phoneLoginStep {
            case .phone: return "Вход по телефону"
            case .choice: return "Выберите способ входа"
            case .password: return "Вход по паролю"
            case .code: return "Вход по SMS"
            }
        } else {
            switch viewModel.registrationStep {
            case .form: return "Создание кабинета"
            case .code: return "Подтверждение телефона"
            }
        }
    }
    
    private var subtitleText: String {
        if selectedTab == 0 {
            switch viewModel.phoneLoginStep {
            case .phone:
                return "Введите номер телефона, чтобы проверить кабинет продавца."
            case .choice:
                return "Кабинет \(viewModel.pendingLoginShopName.ifEmpty("продавца")) найден. Выберите, как войти."
            case .password:
                return "Кабинет \(viewModel.pendingLoginShopName.ifEmpty("продавца"))\nВведите пароль от аккаунта."
            case .code:
                return "Введите 6-значный код из SMS, отправленного на \(phone.maskedPhone())."
            }
        } else {
            switch viewModel.registrationStep {
            case .form:
                return "Заполните основные данные. Название магазина добавим позже в профиле."
            case .code:
                return "Введите 6-значный код из SMS, отправленного на \(phone)."
            }
        }
    }
    
    @ViewBuilder
    private var formContent: some View {
        if selectedTab == 0 {
            loginForm
        } else {
            registrationForm
        }
    }
    
    @ViewBuilder
    private var loginForm: some View {
        switch viewModel.phoneLoginStep {
        case .phone:
            SellerTextField(title: "Телефон", text: $phone, keyboardType: .phonePad)
        case .choice:
            VStack(spacing: 12) {
                Button("Войти по SMS-коду") {
                    Task { await viewModel.requestPhoneLoginCode() }
                    viewModel.goToPhoneLoginCode()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Войти по паролю") {
                    viewModel.goToPhoneLoginPassword()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Войти по другому номеру телефона") {
                    viewModel.resetPhoneLogin()
                    phone = "+7"
                }
                .foregroundColor(.sellerMuted)
            }
        case .password:
            VStack(spacing: 12) {
                SellerTextField(title: "Пароль", text: $loginPassword, isSecure: true)
                Button("Войти по другому номеру телефона") {
                    viewModel.resetPhoneLogin()
                    phone = "+7"
                    loginPassword = ""
                }
                .foregroundColor(.sellerMuted)
            }
        case .code:
            VStack(spacing: 12) {
                SellerTextField(title: "Код из SMS", text: $loginCode, keyboardType: .numberPad)
                Button("Отправить код повторно") {
                    Task { await viewModel.requestPhoneLoginCode() }
                }
                .foregroundColor(.sellerMuted)
                Button("Войти по другому номеру телефона") {
                    viewModel.resetPhoneLogin()
                    phone = "+7"
                    loginCode = ""
                }
                .foregroundColor(.sellerMuted)
            }
        }
    }
    
    @ViewBuilder
    private var registrationForm: some View {
        switch viewModel.registrationStep {
        case .form:
            VStack(spacing: 12) {
                SellerTextField(title: "Телефон", text: $phone, keyboardType: .phonePad)
                SellerTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                SellerTextField(title: "Пароль", text: $password, isSecure: true)
                SellerTextField(title: "Имя", text: $firstName)
                SellerTextField(title: "Фамилия", text: $lastName)
            }
        case .code:
            VStack(spacing: 12) {
                SellerTextField(title: "Код из SMS", text: $registrationCode, keyboardType: .numberPad)
                Button("Отправить код повторно") {
                    Task { await viewModel.resendRegistrationCode() }
                }
                .foregroundColor(.sellerMuted)
                Button("Изменить телефон") {
                    viewModel.registrationStep = .form
                    registrationCode = ""
                }
                .foregroundColor(.sellerMuted)
            }
        }
    }
    
    private var primaryButton: some View {
        let title = primaryButtonTitle
        return Group {
            if !title.isEmpty {
                Button(action: {
                    Task { await primaryAction() }
                }) {
                    Text(title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.sellerBlack)
                        .cornerRadius(26)
                }
                .disabled(viewModel.isBusy)
            }
        }
    }
    
    private var primaryButtonTitle: String {
        if selectedTab == 0 {
            switch viewModel.phoneLoginStep {
            case .phone: return "Продолжить"
            case .choice: return ""
            case .password: return "Войти"
            case .code: return "Подтвердить"
            }
        } else {
            switch viewModel.registrationStep {
            case .form: return "Создать кабинет"
            case .code: return "Подтвердить"
            }
        }
    }
    
    private func primaryAction() async {
        if selectedTab == 0 {
            switch viewModel.phoneLoginStep {
            case .phone:
                await viewModel.beginPhoneLogin(phone: phone)
            case .password:
                await viewModel.login(phone: phone, email: viewModel.pendingLoginEmail, password: loginPassword)
            case .code:
                await viewModel.confirmPhoneLoginCode(code: loginCode)
            case .choice:
                break
            }
        } else {
            switch viewModel.registrationStep {
            case .form:
                guard !phone.isEmpty, !email.isEmpty, !password.isEmpty else {
                    viewModel.setError("Введите телефон, email и пароль")
                    return
                }
                await viewModel.register(request: SellerRegisterRequest(
                    email: email,
                    phone: phone,
                    password: password,
                    firstName: firstName.isEmpty ? nil : firstName,
                    lastName: lastName.isEmpty ? nil : lastName,
                    shopName: nil,
                    description: nil
                ))
            case .code:
                guard registrationCode.count == 6 else {
                    viewModel.setError("Введите 6-значный код")
                    return
                }
                await viewModel.confirmRegistrationCode(code: registrationCode)
            }
        }
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
