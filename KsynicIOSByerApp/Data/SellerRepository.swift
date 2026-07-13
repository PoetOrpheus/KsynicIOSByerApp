import Foundation

actor SellerRepository {
    static let shared = SellerRepository()
    
    private let api = SellerAPIService.shared
    
    private init() {}
    
    func healthCheck() async -> Bool {
        await api.healthCheck()
    }
    
    func register(request: SellerRegisterRequest) async throws -> SellerAuthResponse {
        try await api.register(body: request)
    }
    
    func lookup(phone: String) async throws -> SellerLookupResponse {
        try await api.lookup(phone: phone)
    }
    
    func login(request: SellerLoginRequest) async throws -> SellerAuthResponse {
        try await api.login(body: request)
    }
    
    func getSeller(sellerId: String) async throws -> SellerDetailsResponse {
        try await api.getSeller(sellerId: sellerId)
    }
    
    func updateSeller(sellerId: String, request: UpdateSellerRequest) async throws -> SellerDetailsResponse {
        try await api.updateSeller(sellerId: sellerId, body: request)
    }
    
    func deleteSeller(sellerId: String) async throws -> ApiMessageResponse {
        try await api.deleteSeller(sellerId: sellerId)
    }
    
    func verifyPassword(sellerId: String, password: String) async throws -> ApiMessageResponse {
        try await api.verifyPassword(sellerId: sellerId, body: VerifyPasswordRequest(password: password))
    }
    
    func requestPhoneChange(sellerId: String, phone: String) async throws -> ContactVerificationResponse {
        try await api.requestPhoneChange(sellerId: sellerId, body: PhoneChangeRequest(phone: phone))
    }
    
    func confirmPhoneChange(sellerId: String, phone: String, code: String) async throws -> SellerDetailsResponse {
        try await api.confirmPhoneChange(sellerId: sellerId, body: PhoneChangeConfirmRequest(phone: phone, code: code))
    }
    
    func getDocuments(sellerId: String) async throws -> SellerDocumentsResponse {
        try await api.getDocuments(sellerId: sellerId)
    }
    
    func uploadDocument(sellerId: String, request: UploadSellerDocumentRequest) async throws -> SellerDocumentResponse {
        try await api.uploadDocument(sellerId: sellerId, body: request)
    }
    
    func deleteDocument(sellerId: String, documentId: String) async throws -> ApiMessageResponse {
        try await api.deleteDocument(sellerId: sellerId, documentId: documentId)
    }
    
    func requestContactVerification(sellerId: String, channel: String, method: String? = nil) async throws -> ContactVerificationResponse {
        try await api.requestContactVerification(sellerId: sellerId, body: ContactVerificationRequest(channel: channel, method: method))
    }
    
    func confirmContactVerification(sellerId: String, channel: String, code: String) async throws -> ContactVerificationResponse {
        try await api.confirmContactVerification(sellerId: sellerId, body: ContactVerificationConfirmRequest(channel: channel, code: code))
    }
    
    func submitVerificationRequest(sellerId: String) async throws -> VerificationRequestResponse {
        try await api.submitVerificationRequest(sellerId: sellerId)
    }
    
    func testCompleteVerification(sellerId: String) async throws -> VerificationRequestResponse {
        try await api.testCompleteVerification(sellerId: sellerId)
    }
    
    func getDashboard(sellerId: String, limit: Int = 20) async throws -> SellerDashboardResponse {
        try await api.getDashboard(sellerId: sellerId, limit: limit)
    }
    
    func getAnalytics(sellerId: String) async throws -> SellerAnalyticsResponse {
        try await api.getAnalytics(sellerId: sellerId)
    }
    
    func getSellerReviews(sellerId: String, limit: Int = 50) async throws -> SellerReviewsResponse {
        try await api.getSellerReviews(sellerId: sellerId, limit: limit)
    }
    
    func getProductReviews(productId: String, limit: Int = 50) async throws -> ProductReviewsResponse {
        try await api.getProductReviews(productId: productId, limit: limit)
    }
    
    func getPickupPoints(city: String? = nil) async throws -> PickupPointsResponse {
        try await api.getPickupPoints(city: city)
    }
    
    func getProducts(sellerId: String, page: Int = 1, limit: Int = 30, status: String? = nil) async throws -> SellerProductsResponse {
        try await api.getProducts(sellerId: sellerId, page: page, limit: limit, status: status)
    }
    
    func getProduct(sellerId: String, productId: String) async throws -> SellerProductResponse {
        try await api.getProduct(sellerId: sellerId, productId: productId)
    }
    
    func createProduct(sellerId: String, request: UpsertSellerProductRequest) async throws -> SellerProductResponse {
        try await api.createProduct(sellerId: sellerId, body: request)
    }
    
    func updateProduct(sellerId: String, productId: String, request: UpsertSellerProductRequest) async throws -> SellerProductResponse {
        try await api.updateProduct(sellerId: sellerId, productId: productId, body: request)
    }
    
    func updateProductStatus(sellerId: String, productId: String, status: String) async throws -> SellerProductResponse {
        try await api.updateProductStatus(sellerId: sellerId, productId: productId, body: ProductStatusRequest(status: status))
    }
    
    func deleteProduct(sellerId: String, productId: String) async throws -> ApiMessageResponse {
        try await api.deleteProduct(sellerId: sellerId, productId: productId)
    }
    
    func getCategories(level: Int? = nil, parentId: String? = nil) async throws -> CategoryResponse {
        try await api.getCategories(level: level, parentId: parentId)
    }
    
    func getSpecificationTemplate(categoryId: String) async throws -> CategorySpecTemplateResponse {
        try await api.getSpecificationTemplate(categoryId: categoryId)
    }
}
