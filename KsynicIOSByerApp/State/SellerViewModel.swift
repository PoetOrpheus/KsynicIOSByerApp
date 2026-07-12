import Foundation
import SwiftUI

enum ServerAvailabilityState {
    case checking, available, unavailable
}

enum PhoneLoginStep {
    case phone, choice, password, code
}

enum RegistrationStep {
    case form, code
}

@MainActor
final class SellerViewModel: ObservableObject {
    
    // MARK: - Session & global state
    
    @Published var session: SellerSession
    @Published var serverState: ServerAvailabilityState = .checking
    @Published var serverStatusMessage: String = "Проверяем подключение к серверу"
    @Published var isBusy: Bool = false
    @Published var errorMessage: String?
    @Published var noticeMessage: String?
    
    // MARK: - Data
    
    @Published var profile: SellerProfileDto?
    @Published var documents: [SellerDocumentDto] = []
    @Published var dashboard: SellerDashboardDto?
    @Published var analytics: SellerAnalyticsDto?
    @Published var products: [SellerProductDto] = []
    @Published var categories: [CategoryDto] = []
    @Published var pickupPoints: [PickupPointDto] = []
    @Published var specificationGroups: [SpecificationGroupDto] = []
    @Published var sellerReviews: SellerReviewsPayloadDto?
    @Published var reviewsProductFilter: String?
    @Published var productEditor: SellerProductDto?
    @Published var productsStatusFilter: String?
    
    // MARK: - Auth state
    
    @Published var phoneLoginStep: PhoneLoginStep = .phone
    @Published var registrationStep: RegistrationStep = .form
    @Published var pendingLoginPhone: String = ""
    @Published var pendingLoginEmail: String = ""
    @Published var pendingLoginShopName: String = ""
    @Published var lastVerificationCode: ContactVerificationDto?
    
    private let repository = SellerRepository.shared
    private let sessionStore = SellerSessionStore.shared
    private var pollingTask: Task<Void, Never>?
    
    init() {
        self.session = sessionStore.load()
        Task {
            await checkServer()
            if session.isLoggedIn {
                await refreshAll()
            }
        }
    }
    
    // MARK: - Server
    
    func checkServer() async {
        serverState = .checking
        serverStatusMessage = "Проверяем подключение к серверу"
        let available = await repository.healthCheck()
        if available {
            serverState = .available
            serverStatusMessage = "Сервер доступен"
        } else {
            serverState = .unavailable
            serverStatusMessage = "Сервер временно не работает"
        }
    }
    
    func retryServerCheck() async {
        await checkServer()
        if serverState == .available && session.isLoggedIn {
            await refreshAll()
        }
    }
    
    // MARK: - Auth helpers
    
    func clearMessages() {
        errorMessage = nil
        noticeMessage = nil
    }
    
    func setError(_ message: String) {
        errorMessage = message
    }
    
    private func setNotice(_ message: String) {
        noticeMessage = message
    }
    
    private func runWithLoading(_ operation: () async throws -> Void) async {
        isBusy = true
        clearMessages()
        do {
            try await operation()
        } catch let error as APIError {
            setError(error.errorDescription ?? "Неизвестная ошибка")
        } catch {
            setError(error.localizedDescription)
        }
        isBusy = false
    }
    
    // MARK: - Login flow
    
    func beginPhoneLogin(phone: String) async {
        await runWithLoading {
            let response = try await repository.lookup(phone: phone)
            guard response.exists == true, let sellerId = response.sellerId else {
                setError("Данный номер не найден. Попробуйте ввести другой номер или зарегистрируйте новый аккаунт")
                return
            }
            pendingLoginPhone = phone
            pendingLoginEmail = response.email ?? ""
            pendingLoginShopName = response.shopName ?? ""
            session.sellerId = sellerId
            sessionStore.save(session)
            let details = try await repository.getSeller(sellerId: sellerId)
            profile = details.data
            if let data = details.data {
                updateSession(from: data)
            }
            phoneLoginStep = .choice
            setNotice("Кабинет продавца найден")
        }
    }
    
    func login(phone: String, email: String, password: String) async {
        await runWithLoading {
            let response = try await repository.login(request: SellerLoginRequest(email: email, phone: phone, password: password))
            guard let payload = response.data, let seller = payload.seller, let user = payload.user else {
                setError("Сервер не вернул данные продавца")
                return
            }
            updateSession(from: seller, user: user)
            phoneLoginStep = .phone
            setNotice(response.message ?? "Добро пожаловать в кабинет продавца")
            await refreshAll()
            startPolling()
        }
    }
    
    func goToPhoneLoginPassword() {
        phoneLoginStep = .password
    }
    
    func goToPhoneLoginCode() {
        phoneLoginStep = .code
    }
    
    func requestPhoneLoginCode() async {
        await runWithLoading {
            let response = try await repository.requestContactVerification(
                sellerId: session.sellerId,
                channel: "phone",
                method: "sms"
            )
            lastVerificationCode = response.data
            setNotice(response.message ?? "Код отправлен")
        }
    }
    
    func confirmPhoneLoginCode(code: String) async {
        await runWithLoading {
            _ = try await repository.confirmContactVerification(sellerId: session.sellerId, channel: "phone", code: code)
            let details = try await repository.getSeller(sellerId: session.sellerId)
            if let data = details.data {
                updateSession(from: data)
            }
            phoneLoginStep = .phone
            setNotice("Вход выполнен")
            await refreshAll()
            startPolling()
        }
    }
    
    func resetPhoneLogin() {
        phoneLoginStep = .phone
        pendingLoginPhone = ""
        pendingLoginEmail = ""
        pendingLoginShopName = ""
    }
    
    // MARK: - Registration
    
    func register(request: SellerRegisterRequest) async {
        await runWithLoading {
            let response = try await repository.register(request: request)
            guard let payload = response.data, let seller = payload.seller else {
                setError("Данные регистрации утеряны")
                return
            }
            pendingLoginPhone = request.phone
            session.sellerId = seller.id ?? ""
            session.email = request.email
            session.phone = request.phone
            registrationStep = .code
            setNotice("Код отправлен")
        }
    }
    
    func resendRegistrationCode() async {
        await runWithLoading {
            let response = try await repository.requestContactVerification(
                sellerId: session.sellerId,
                channel: "phone",
                method: "sms"
            )
            lastVerificationCode = response.data
            setNotice(response.message ?? "Код отправлен")
        }
    }
    
    func confirmRegistrationCode(code: String) async {
        await runWithLoading {
            _ = try await repository.confirmContactVerification(sellerId: session.sellerId, channel: "phone", code: code)
            let details = try await repository.getSeller(sellerId: session.sellerId)
            if let profile = details.data {
                updateSession(from: profile)
            }
            registrationStep = .form
            setNotice("Телефон подтверждён")
            await refreshAll()
            startPolling()
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        session = SellerSession()
        sessionStore.clear()
        profile = nil
        documents = []
        dashboard = nil
        analytics = nil
        products = []
        sellerReviews = nil
        stopPolling()
        setNotice("Вы вышли из кабинета продавца")
    }
    
    // MARK: - Refresh
    
    func refreshAll() async {
        guard session.isLoggedIn, !session.sellerId.isEmpty else { return }
        await refreshProfile()
        await refreshDashboard()
        await refreshDocuments()
        await loadProducts()
        await loadSellerReviews()
    }
    
    func refreshProfile() async {
        guard !session.sellerId.isEmpty else { return }
        await runWithLoading {
            let response = try await repository.getSeller(sellerId: session.sellerId)
            if let data = response.data {
                profile = data
                updateSession(from: data)
            }
        }
    }
    
    func refreshDashboard() async {
        guard !session.sellerId.isEmpty else { return }
        await runWithLoading {
            let dashboardResponse = try await repository.getDashboard(sellerId: session.sellerId)
            let analyticsResponse = try await repository.getAnalytics(sellerId: session.sellerId)
            dashboard = dashboardResponse.data
            analytics = analyticsResponse.data
        }
    }
    
    func refreshDocuments() async {
        guard !session.sellerId.isEmpty else { return }
        await runWithLoading {
            let response = try await repository.getDocuments(sellerId: session.sellerId)
            documents = response.data ?? []
        }
    }
    
    func loadProducts(status: String? = nil) async {
        guard !session.sellerId.isEmpty else { return }
        await runWithLoading {
            let response = try await repository.getProducts(sellerId: session.sellerId, status: status)
            products = response.data ?? []
        }
    }
    
    func loadSellerReviews(limit: Int = 200) async {
        guard !session.sellerId.isEmpty else { return }
        await runWithLoading {
            let response = try await repository.getSellerReviews(sellerId: session.sellerId, limit: limit)
            sellerReviews = response.data
        }
    }
    
    // MARK: - Products
    
    func updateProductStatus(id: String, status: String) async {
        await runWithLoading {
            _ = try await repository.updateProductStatus(sellerId: session.sellerId, productId: id, status: status)
            setNotice("Статус товара обновлен")
            await loadProducts(status: productsStatusFilter)
        }
    }
    
    func requestProductPublication(id: String) async {
        await updateProductStatus(id: id, status: "pending")
        setNotice("Товар отправлен на модерацию")
    }
    
    func deleteProduct(id: String) async {
        await runWithLoading {
            _ = try await repository.deleteProduct(sellerId: session.sellerId, productId: id)
            setNotice("Товар удален")
            await loadProducts(status: productsStatusFilter)
        }
    }
    
    func beginProductEdit(id: String) async {
        await runWithLoading {
            let response = try await repository.getProduct(sellerId: session.sellerId, productId: id)
            productEditor = response.data
            setNotice("Открыт режим редактирования")
        }
    }
    
    func clearProductEditor() {
        productEditor = nil
    }
    
    func createProduct(request: UpsertSellerProductRequest) async {
        await runWithLoading {
            _ = try await repository.createProduct(sellerId: session.sellerId, request: request)
            setNotice("Товар создан")
            await loadProducts(status: productsStatusFilter)
        }
    }
    
    func updateProduct(productId: String, request: UpsertSellerProductRequest) async {
        await runWithLoading {
            _ = try await repository.updateProduct(sellerId: session.sellerId, productId: productId, request: request)
            setNotice("Товар обновлен")
            await loadProducts(status: productsStatusFilter)
        }
    }
    
    // MARK: - Profile
    
    func saveProfile(request: UpdateSellerRequest) async {
        guard !session.sellerId.isEmpty else { return }
        await runWithLoading {
            let response = try await repository.updateSeller(sellerId: session.sellerId, request: request)
            if let data = response.data {
                profile = data
                updateSession(from: data)
            }
            setNotice("Профиль продавца сохранен")
        }
    }
    
    func setNotificationsEnabled(_ enabled: Bool) {
        session.notificationsEnabled = enabled
        sessionStore.save(session)
        if enabled {
            startPolling()
        } else {
            stopPolling()
        }
    }
    
    func canCreateProductReason() -> String? {
        guard session.isActive else { return "Аккаунт не активен. Дождитесь проверки" }
        guard session.documentsVerified else { return "Заполните и отправьте документы на проверку" }
        guard !session.pickupPointId.isEmpty else { return "Укажите пункт выдачи заказов" }
        return nil
    }
    
    var canCreateProduct: Bool {
        canCreateProductReason() == nil
    }
    
    // MARK: - Security
    
    func verifyPassword(password: String) async throws -> Bool {
        let response = try await repository.verifyPassword(sellerId: session.sellerId, password: password)
        return response.success == true
    }
    
    func requestPhoneChange(newPhone: String) async {
        await runWithLoading {
            let response = try await repository.requestPhoneChange(sellerId: session.sellerId, phone: newPhone)
            lastVerificationCode = response.data
            setNotice(response.message ?? "Код отправлен на новый номер")
        }
    }
    
    func confirmPhoneChange(newPhone: String, code: String) async {
        await runWithLoading {
            let response = try await repository.confirmPhoneChange(sellerId: session.sellerId, phone: newPhone, code: code)
            if let data = response.data {
                profile = data
                updateSession(from: data)
            }
            setNotice("Телефон изменен")
        }
    }
    
    // MARK: - Documents
    
    func uploadDocument(request: UploadSellerDocumentRequest) async {
        await runWithLoading {
            _ = try await repository.uploadDocument(sellerId: session.sellerId, request: request)
            setNotice("Документы загружены")
            await refreshDocuments()
        }
    }
    
    func deleteDocument(id: String) async {
        await runWithLoading {
            _ = try await repository.deleteDocument(sellerId: session.sellerId, documentId: id)
            setNotice("Документ удален")
            await refreshDocuments()
        }
    }
    
    func submitVerification() async {
        await runWithLoading {
            let response = try await repository.submitVerificationRequest(sellerId: session.sellerId)
            setNotice(response.message ?? "Заявка отправлена")
            await refreshProfile()
        }
    }
    
    // MARK: - Catalog
    
    func loadCategories() async {
        await runWithLoading {
            let response = try await repository.getCategories()
            categories = response.data ?? []
        }
    }
    
    func loadPickupPoints(city: String? = nil) async {
        await runWithLoading {
            let response = try await repository.getPickupPoints(city: city)
            pickupPoints = response.data ?? []
        }
    }
    
    func loadSpecificationTemplate(categoryId: String) async {
        await runWithLoading {
            let response = try await repository.getSpecificationTemplate(categoryId: categoryId)
            specificationGroups = response.data?.groups ?? []
        }
    }
    
    func rootCategories() -> [CategoryDto] {
        categories.filter { ($0.level ?? 0) == 1 }
    }
    
    func childrenOf(parentId: String) -> [CategoryDto] {
        categories.filter { $0.parentId == parentId }
    }
    
    func categoryName(id: String?) -> String {
        guard let id = id else { return "" }
        return categories.first { $0.id == id }?.name ?? ""
    }
    
    // MARK: - Session updating
    
    private func updateSession(from seller: SellerAccountDto, user: SellerUserDto) {
        session.isLoggedIn = true
        session.sellerId = seller.id ?? session.sellerId
        session.shopName = seller.shopName ?? session.shopName
        session.sellerStatus = seller.status ?? session.sellerStatus
        session.isActive = seller.isActive ?? session.isActive
        session.isSellerVerified = seller.isVerified ?? session.isSellerVerified
        session.documentsVerified = seller.documentsVerified ?? session.documentsVerified
        session.notificationsEnabled = seller.notificationsEnabled ?? session.notificationsEnabled
        session.phone = user.phone ?? session.phone
        session.email = user.email ?? session.email
        session.firstName = user.firstName ?? session.firstName
        session.lastName = user.lastName ?? session.lastName
        session.isPhoneVerified = user.isPhoneVerified ?? session.isPhoneVerified
        session.isEmailVerified = user.isEmailVerified ?? session.isEmailVerified
        sessionStore.save(session)
    }
    
    private func updateSession(from profile: SellerProfileDto) {
        session.isLoggedIn = true
        session.sellerId = profile.sellerId ?? profile.id ?? session.sellerId
        session.sellerProfileId = profile.sellerProfileId ?? session.sellerProfileId
        session.shopName = profile.shopName ?? session.shopName
        session.description = profile.description ?? session.description
        session.sellerStatus = profile.sellerStatus ?? session.sellerStatus
        session.isActive = profile.sellerIsActive ?? session.isActive
        session.isSellerVerified = profile.sellerIsVerified ?? session.isSellerVerified
        session.documentsVerified = profile.documentsVerified ?? session.documentsVerified
        session.notificationsEnabled = profile.notificationsEnabled ?? session.notificationsEnabled
        session.phone = profile.phone ?? session.phone
        session.email = profile.email ?? session.email
        session.firstName = profile.firstName ?? session.firstName
        session.lastName = profile.lastName ?? session.lastName
        session.isPhoneVerified = profile.isPhoneVerified ?? session.isPhoneVerified
        session.isEmailVerified = profile.isEmailVerified ?? session.isEmailVerified
        session.pickupPointId = profile.pickupPointId ?? session.pickupPointId
        session.pickupPoint = profile.pickupPointName ?? profile.pickupPoint ?? session.pickupPoint
        sessionStore.save(session)
    }
    
    // MARK: - Polling
    
    private func startPolling() {
        guard session.isLoggedIn && session.notificationsEnabled else { return }
        stopPolling()
        pollingTask = Task {
            var lastToShipCount = -1
            while !Task.isCancelled {
                do {
                    let response = try await repository.getDashboard(sellerId: session.sellerId, limit: 20)
                    if let toShip = response.data?.toShip {
                        if lastToShipCount >= 0 && toShip.count > lastToShipCount {
                            postLocalNotification(count: toShip.count - lastToShipCount)
                        }
                        lastToShipCount = toShip.count
                    }
                } catch {
                    // ignore polling errors
                }
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
            }
        }
    }
    
    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
    
    private func postLocalNotification(count: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Ksynic Seller"
        content.body = count == 1 ? "У вас новый заказ" : "У вас \(count) новых заказа"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "seller_new_orders_\(UUID().uuidString)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
