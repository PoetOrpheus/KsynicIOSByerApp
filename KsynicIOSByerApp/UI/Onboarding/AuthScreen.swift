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
        NavigationView {
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
                                    .foregroundColor(.sellerMutedDark)
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
        .navigationBarHidden(true)
        .accentColor(.sellerInkDark)
    }
    .preferredColorScheme(.light)
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 30)
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Text("Ksynic Seller")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
            Text("Кабинет продавца маркетплейса")
                .font(.sellerBody)
                .foregroundColor(.white.opacity(0.68))
            Spacer().frame(height: 20)
        }
        .frame(height: 260)
    }
    
    private var authModeSwitch: some View {
        HStack(spacing: 4) {
            modeButton(title: "Вход", index: 0)
            modeButton(title: "Регистрация", index: 1)
        }
        .padding(4)
        .background(Color.sellerCloudLight)
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
                .foregroundColor(selectedTab == index ? .sellerInkDark : .sellerMutedDark)
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
                .foregroundColor(.sellerInkDark)
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
            SellerTextField(title: "Телефон", text: $phone, keyboardType: .phonePad, textColor: .sellerInkDark, surfaceColor: .white)
        case .choice:
            VStack(spacing: 12) {
                Button("Войти по SMS-коду") {
                    Task { await viewModel.requestPhoneLoginCode() }
                    viewModel.goToPhoneLoginCode()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isBusy)
                
                Button("Войти по паролю") {
                    viewModel.goToPhoneLoginPassword()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isBusy)
                
                Button("Войти по другому номеру телефона") {
                    viewModel.resetPhoneLogin()
                    phone = "+7"
                }
                .foregroundColor(.sellerMutedDark)
            }
        case .password:
            VStack(spacing: 12) {
                SellerTextField(title: "Email", text: $email, keyboardType: .emailAddress, textColor: .sellerInkDark, surfaceColor: .white)
                SellerTextField(title: "Пароль", text: $loginPassword, isSecure: true, textColor: .sellerInkDark, surfaceColor: .white)
                Button("Войти по другому номеру телефона") {
                    viewModel.resetPhoneLogin()
                    phone = "+7"
                    email = ""
                    loginPassword = ""
                }
                .foregroundColor(.sellerMutedDark)
            }
        case .code:
            VStack(spacing: 12) {
                SellerTextField(title: "Код из SMS", text: $loginCode, keyboardType: .numberPad, textColor: .sellerInkDark, surfaceColor: .white)
                Button("Отправить код повторно") {
                    Task { await viewModel.requestPhoneLoginCode() }
                }
                .foregroundColor(.sellerMutedDark)
                .disabled(viewModel.isBusy)
                Button("Войти по другому номеру телефона") {
                    viewModel.resetPhoneLogin()
                    phone = "+7"
                    loginCode = ""
                }
                .foregroundColor(.sellerMutedDark)
            }
        }
    }
    
    @ViewBuilder
    private var registrationForm: some View {
        switch viewModel.registrationStep {
        case .form:
            VStack(spacing: 12) {
                SellerTextField(title: "Телефон", text: $phone, keyboardType: .phonePad, textColor: .sellerInkDark, surfaceColor: .white)
                SellerTextField(title: "Email", text: $email, keyboardType: .emailAddress, textColor: .sellerInkDark, surfaceColor: .white)
                SellerTextField(title: "Пароль", text: $password, isSecure: true, textColor: .sellerInkDark, surfaceColor: .white)
                SellerTextField(title: "Имя", text: $firstName, textColor: .sellerInkDark, surfaceColor: .white)
                SellerTextField(title: "Фамилия", text: $lastName, textColor: .sellerInkDark, surfaceColor: .white)
            }
        case .code:
            VStack(spacing: 12) {
                SellerTextField(title: "Код из SMS", text: $registrationCode, keyboardType: .numberPad, textColor: .sellerInkDark, surfaceColor: .white)
                Button("Отправить код повторно") {
                    Task { await viewModel.resendRegistrationCode() }
                }
                .foregroundColor(.sellerMutedDark)
                .disabled(viewModel.isBusy)
                Button("Изменить телефон") {
                    viewModel.registrationStep = .form
                    registrationCode = ""
                }
                .foregroundColor(.sellerMutedDark)
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
                    if viewModel.isBusy {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.sellerBlack)
                            .cornerRadius(26)
                    } else {
                        Text(title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.sellerBlack)
                            .cornerRadius(26)
                    }
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
                await viewModel.login(phone: phone, email: email, password: loginPassword)
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
