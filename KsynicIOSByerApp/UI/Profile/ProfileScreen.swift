import SwiftUI

struct ProfileScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    
    @State private var showEditProfile: Bool = false
    @State private var showEditPickupPoint: Bool = false
    @State private var showChangePhone: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                shopDataCard
                requisitesCard
                pvzCard
                notificationsCard
                securityCard
            }
            .padding(16)
        }
        .refreshable {
            await viewModel.refreshProfile()
        }
        .onAppear {
            Task { await viewModel.refreshProfile() }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileDialog(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditPickupPoint) {
            EditPickupPointDialog(viewModel: viewModel)
        }
        .sheet(isPresented: $showChangePhone) {
            ChangePhoneDialog(viewModel: viewModel)
        }
        .background(Color.sellerBackground)
    }
    
    private var header: some View {
        ZStack {
            Color.sellerBlack
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.sellerSurface)
                        .frame(width: 64, height: 64)
                    Text(initials)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.session.shopName.isEmpty ? "Мой магазин" : viewModel.session.shopName)
                        .font(.sellerHeadline)
                        .foregroundColor(.white)
                    StatusPill(text: statusText, color: statusColor)
                    Text("\(viewModel.session.phone)\n\(viewModel.session.email)")
                        .font(.sellerCaption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(20)
        }
        .frame(height: 140)
        .cornerRadius(16)
    }
    
    private var initials: String {
        let first = viewModel.session.firstName.prefix(1).uppercased()
        let last = viewModel.session.lastName.prefix(1).uppercased()
        return first + last
    }
    
    private var statusText: String {
        if viewModel.session.isSellerVerified { return "Проверен" }
        if viewModel.session.documentsVerified { return "На проверке" }
        return "Активен"
    }
    
    private var statusColor: Color {
        if viewModel.session.isSellerVerified { return .sellerGreen }
        if viewModel.session.documentsVerified { return .sellerOrange }
        return .sellerBlue
    }
    
    private var shopDataCard: some View {
        FormCard(title: "Данные магазина") {
            VStack(spacing: 12) {
                infoRow(title: "Название", value: viewModel.session.shopName.ifEmpty("Не указано"))
                infoRow(title: "Описание", value: viewModel.session.description.ifEmpty("Не указано"))
                infoRow(title: "Владелец", value: viewModel.session.displayName)
                infoRow(title: "Email", value: viewModel.session.email.ifEmpty("Не указан"))
            }
            .onTapGesture { showEditProfile = true }
        }
    }
    
    private var requisitesCard: some View {
        FormCard(title: "Реквизиты") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(requisitesFilled ? "Реквизиты заполнены" : "Реквизиты не заполнены")
                        .font(.sellerBody)
                        .fontWeight(.semibold)
                    Text(requisitesFilled ? "Нажмите, чтобы перейти к документам" : "Заполните в разделе Документы")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.sellerMuted)
            }
        }
    }
    
    private var requisitesFilled: Bool {
        guard let profile = viewModel.profile else { return false }
        return !(profile.legalName ?? "").isEmpty && !(profile.taxId ?? "").isEmpty
    }
    
    private var pvzCard: some View {
        FormCard(title: "Пункт выдачи заказов") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.session.pickupPointId.isEmpty ? "ПВЗ не выбран" : "ПВЗ выбран")
                        .font(.sellerBody)
                        .fontWeight(.semibold)
                    Text(viewModel.session.pickupPoint.isEmpty ? "Выберите пункт выдачи" : viewModel.session.pickupPoint)
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.sellerMuted)
            }
            .onTapGesture { showEditPickupPoint = true }
        }
    }
    
    private var notificationsCard: some View {
        FormCard(title: "Уведомления") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Новые заказы")
                        .font(.sellerBody)
                        .fontWeight(.semibold)
                    Text(viewModel.session.notificationsEnabled ? "Уведомления включены" : "Уведомления выключены")
                        .font(.sellerCaption)
                        .foregroundColor(.sellerMuted)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.session.notificationsEnabled },
                    set: { viewModel.setNotificationsEnabled($0) }
                ))
                .toggleStyle(.switch)
            }
        }
    }
    
    private var securityCard: some View {
        FormCard(title: "Безопасность") {
            VStack(spacing: 12) {
                Button(action: { showChangePhone = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Изменить номер телефона")
                                .font(.sellerBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.sellerInk)
                            Text(viewModel.session.phone)
                                .font(.sellerCaption)
                                .foregroundColor(.sellerMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.sellerMuted)
                    }
                }
                
                Button(action: { viewModel.logout() }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Выйти из аккаунта")
                                .font(.sellerBody)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                            Text("Завершить сессию")
                                .font(.sellerCaption)
                                .foregroundColor(.sellerMuted)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.sellerBody)
                .foregroundColor(.sellerMuted)
            Spacer()
            Text(value)
                .font(.sellerBody)
                .foregroundColor(.sellerInk)
        }
    }
}

struct EditProfileDialog: View {
    @ObservedObject var viewModel: SellerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var shopName: String = ""
    @State private var description: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    SellerTextField(title: "Название магазина", text: $shopName)
                    SellerTextField(title: "Описание", text: $description, minLines: 3)
                    SellerTextField(title: "Имя", text: $firstName)
                    SellerTextField(title: "Фамилия", text: $lastName)
                    SellerTextField(title: "Email", text: $email, keyboardType: .emailAddress)
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.sellerInk)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        Task {
                            await viewModel.saveProfile(request: UpdateSellerRequest(
                                shopName: shopName.isEmpty ? nil : shopName,
                                description: description.isEmpty ? nil : description,
                                firstName: firstName.isEmpty ? nil : firstName,
                                lastName: lastName.isEmpty ? nil : lastName,
                                email: email.isEmpty ? nil : email
                            ))
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                shopName = viewModel.session.shopName
                description = viewModel.session.description
                firstName = viewModel.session.firstName
                lastName = viewModel.session.lastName
                email = viewModel.session.email
            }
        }
    }
}

struct EditPickupPointDialog: View {
    @ObservedObject var viewModel: SellerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCity: String = ""
    @State private var selectedPointId: String = ""
    
    private var cities: [String] {
        Array(Set(viewModel.pickupPoints.compactMap { $0.city })).sorted()
    }
    
    private var filteredPoints: [PickupPointDto] {
        viewModel.pickupPoints.filter { $0.city == selectedCity }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Город", selection: $selectedCity) {
                        Text("Выберите город").tag("")
                        ForEach(cities, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }
                    .onChange(of: selectedCity) { _ in
                        selectedPointId = ""
                    }
                    
                    Picker("Пункт выдачи заказов (ПВЗ)", selection: $selectedPointId) {
                        Text("Не выбран").tag("")
                        ForEach(filteredPoints) { point in
                            Text("\(point.name ?? "—"), \(point.address ?? "—")").tag(point.id ?? "")
                        }
                    }
                    .disabled(selectedCity.isEmpty)
                    
                    if selectedCity.isEmpty == false && filteredPoints.isEmpty {
                        Text("Список ПВЗ пуст. Добавьте ПВЗ в админ-панели.")
                            .font(.sellerCaption)
                            .foregroundColor(.sellerMuted)
                    }
                }
            }
            .navigationTitle("Пункт выдачи заказов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.sellerInk)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        Task {
                            await viewModel.saveProfile(request: UpdateSellerRequest(
                                pickupPointId: selectedPointId.isEmpty ? nil : selectedPointId
                            ))
                            dismiss()
                        }
                    }
                    .foregroundColor(.sellerInk)
                }
            }
            .onAppear {
                Task { await viewModel.loadPickupPoints() }
            }
        }
    }
}

struct ChangePhoneDialog: View {
    @ObservedObject var viewModel: SellerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var step: PhoneChangeStep = .password
    @State private var password: String = ""
    @State private var newPhone: String = "+7"
    @State private var code: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                switch step {
                case .password:
                    Text("Введите текущий пароль, чтобы изменить номер телефона.")
                        .font(.sellerBody)
                        .foregroundColor(.sellerMuted)
                    SellerTextField(title: "Пароль", text: $password, isSecure: true)
                    Button("Далее") {
                        Task {
                            do {
                                if try await viewModel.verifyPassword(password: password) {
                                    step = .phone
                                } else {
                                    viewModel.setError("Неверный пароль")
                                }
                            } catch {
                                viewModel.setError(error.localizedDescription)
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                case .phone:
                    Text("Введите новый номер телефона. На него придёт SMS с кодом подтверждения.")
                        .font(.sellerBody)
                        .foregroundColor(.sellerMuted)
                    SellerNumericField(title: "Новый телефон", text: $newPhone, keyboardType: .phonePad)
                    Button("Получить код") {
                        Task { await viewModel.requestPhoneChange(newPhone: newPhone) }
                        step = .code
                    }
                    .buttonStyle(PrimaryButtonStyle())
                case .code:
                    Text("Код отправлен на номер \(newPhone).")
                        .font(.sellerBody)
                        .foregroundColor(.sellerMuted)
                    SellerNumericField(title: "Код из SMS", text: $code, keyboardType: .numberPad)
                    Button("Подтвердить") {
                        Task {
                            await viewModel.confirmPhoneChange(newPhone: newPhone, code: code)
                            step = .done
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                case .done:
                    Text("Номер телефона успешно изменён.")
                        .font(.sellerBody)
                        .foregroundColor(.sellerGreen)
                    Button("Готово") {
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(24)
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if step != .done {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { dismiss() }
                            .foregroundColor(.sellerInk)
                    }
                }
            }
        }
    }
    
    private var stepTitle: String {
        switch step {
        case .password: return "Подтвердите пароль"
        case .phone: return "Новый номер"
        case .code: return "Код из SMS"
        case .done: return "Готово"
        }
    }
}

enum PhoneChangeStep {
    case password, phone, code, done
}
