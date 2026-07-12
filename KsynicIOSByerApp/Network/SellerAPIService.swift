import Foundation

actor SellerAPIService {
    static let shared = SellerAPIService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkConfig.readTimeout
        config.timeoutIntervalForResource = NetworkConfig.writeTimeout
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    // MARK: - Health
    
    func healthCheck() async -> Bool {
        do {
            let _: ApiMessageResponse = try await request(method: "GET", path: "health")
            return true
        } catch {
            logError(error)
            return false
        }
    }
    
    // MARK: - Auth
    
    func register(request: SellerRegisterRequest) async throws -> SellerAuthResponse {
        return try await request(method: "POST", path: "sellers/register", body: request)
    }
    
    func lookup(phone: String) async throws -> SellerLookupResponse {
        return try await request(method: "POST", path: "sellers/lookup", body: SellerLookupRequest(phone: phone))
    }
    
    func login(request: SellerLoginRequest) async throws -> SellerAuthResponse {
        return try await request(method: "POST", path: "sellers/login", body: request)
    }
    
    // MARK: - Profile
    
    func getSeller(sellerId: String) async throws -> SellerDetailsResponse {
        return try await request(method: "GET", path: "sellers/\(sellerId)")
    }
    
    func updateSeller(sellerId: String, request: UpdateSellerRequest) async throws -> SellerDetailsResponse {
        return try await request(method: "PUT", path: "sellers/\(sellerId)", body: request)
    }
    
    func deleteSeller(sellerId: String) async throws -> ApiMessageResponse {
        return try await request(method: "DELETE", path: "sellers/\(sellerId)")
    }
    
    func verifyPassword(sellerId: String, request: VerifyPasswordRequest) async throws -> ApiMessageResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/verify-password", body: request)
    }
    
    func requestPhoneChange(sellerId: String, request: PhoneChangeRequest) async throws -> ContactVerificationResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/phone-change/request", body: request)
    }
    
    func confirmPhoneChange(sellerId: String, request: PhoneChangeConfirmRequest) async throws -> SellerDetailsResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/phone-change/confirm", body: request)
    }
    
    // MARK: - Documents
    
    func getDocuments(sellerId: String) async throws -> SellerDocumentsResponse {
        return try await request(method: "GET", path: "sellers/\(sellerId)/documents")
    }
    
    func uploadDocument(sellerId: String, request: UploadSellerDocumentRequest) async throws -> SellerDocumentResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/documents", body: request)
    }
    
    func deleteDocument(sellerId: String, documentId: String) async throws -> ApiMessageResponse {
        return try await request(method: "DELETE", path: "sellers/\(sellerId)/documents/\(documentId)")
    }
    
    // MARK: - Verification
    
    func requestContactVerification(sellerId: String, request: ContactVerificationRequest) async throws -> ContactVerificationResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/contact-verification/request", body: request)
    }
    
    func confirmContactVerification(sellerId: String, request: ContactVerificationConfirmRequest) async throws -> ContactVerificationResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/contact-verification/confirm", body: request)
    }
    
    func submitVerificationRequest(sellerId: String) async throws -> VerificationRequestResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/verification-request")
    }
    
    func testCompleteVerification(sellerId: String) async throws -> VerificationRequestResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/verification-request/test-complete")
    }
    
    // MARK: - Dashboard & Analytics
    
    func getDashboard(sellerId: String, limit: Int = 20) async throws -> SellerDashboardResponse {
        return try await request(method: "GET", path: "sellers/\(sellerId)/dashboard?limit=\(limit)")
    }
    
    func getAnalytics(sellerId: String) async throws -> SellerAnalyticsResponse {
        return try await request(method: "GET", path: "sellers/\(sellerId)/analytics")
    }
    
    func getSellerReviews(sellerId: String, limit: Int = 50) async throws -> SellerReviewsResponse {
        return try await request(method: "GET", path: "sellers/\(sellerId)/reviews?limit=\(limit)")
    }
    
    func getProductReviews(productId: String, limit: Int = 50) async throws -> ProductReviewsResponse {
        return try await request(method: "GET", path: "products/\(productId)/reviews?limit=\(limit)")
    }
    
    // MARK: - Pickup Points
    
    func getPickupPoints(city: String? = nil) async throws -> PickupPointsResponse {
        var path = "pickup-points"
        if let city = city, !city.isEmpty {
            path += "?city=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)"
        }
        return try await request(method: "GET", path: path)
    }
    
    // MARK: - Products
    
    func getProducts(sellerId: String, page: Int = 1, limit: Int = 30, status: String? = nil) async throws -> SellerProductsResponse {
        var path = "sellers/\(sellerId)/products?page=\(page)&limit=\(limit)"
        if let status = status, !status.isEmpty {
            path += "&status=\(status)"
        }
        return try await request(method: "GET", path: path)
    }
    
    func getProduct(sellerId: String, productId: String) async throws -> SellerProductResponse {
        return try await request(method: "GET", path: "sellers/\(sellerId)/products/\(productId)")
    }
    
    func createProduct(sellerId: String, request: UpsertSellerProductRequest) async throws -> SellerProductResponse {
        return try await request(method: "POST", path: "sellers/\(sellerId)/products", body: request)
    }
    
    func updateProduct(sellerId: String, productId: String, request: UpsertSellerProductRequest) async throws -> SellerProductResponse {
        return try await request(method: "PUT", path: "sellers/\(sellerId)/products/\(productId)", body: request)
    }
    
    func updateProductStatus(sellerId: String, productId: String, request: ProductStatusRequest) async throws -> SellerProductResponse {
        return try await request(method: "PATCH", path: "sellers/\(sellerId)/products/\(productId)/status", body: request)
    }
    
    func deleteProduct(sellerId: String, productId: String) async throws -> ApiMessageResponse {
        return try await request(method: "DELETE", path: "sellers/\(sellerId)/products/\(productId)")
    }
    
    // MARK: - Categories
    
    func getCategories(level: Int? = nil, parentId: String? = nil) async throws -> CategoryResponse {
        var components: [String] = []
        if let level = level {
            components.append("level=\(level)")
        }
        if let parentId = parentId, !parentId.isEmpty {
            components.append("parent_id=\(parentId)")
        }
        components.append("active_only=true")
        let query = components.joined(separator: "&")
        return try await request(method: "GET", path: "categories?\(query)")
    }
    
    func getSpecificationTemplate(categoryId: String) async throws -> CategorySpecTemplateResponse {
        return try await request(method: "GET", path: "categories/\(categoryId)/specifications-template")
    }
    
    // MARK: - Generic request
    
    private func request<T: Decodable>(method: String, path: String, body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: NetworkConfig.apiBaseURL + "/" + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = NetworkConfig.readTimeout
        
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        logRequest(request)
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.serverUnavailable
        }
        
        logResponse(data: data, response: response)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if (200..<300).contains(httpResponse.statusCode) {
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } else {
            let message = extractMessage(from: data)
            throw APIError.httpStatus(httpResponse.statusCode, message)
        }
    }
    
    private func extractMessage(from data: Data) -> String? {
        if let apiMessage = try? decoder.decode(ApiMessageResponse.self, from: data) {
            return apiMessage.message ?? apiMessage.error
        }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json["message"] as? String ?? json["error"] as? String
        }
        return String(data: data, encoding: .utf8)
    }
    
    private func logRequest(_ request: URLRequest) {
        print("➡️ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        if let body = request.httpBody, let string = String(data: body, encoding: .utf8) {
            print("📦 \(string)")
        }
    }
    
    private func logResponse(data: Data, response: URLResponse) {
        if let http = response as? HTTPURLResponse {
            print("⬅️ \(http.statusCode) \(response.url?.absoluteString ?? "")")
        }
        if let string = String(data: data, encoding: .utf8) {
            print("📨 \(string.prefix(2000))")
        }
    }
    
    private func logError(_ error: Error) {
        print("❌ \(error.localizedDescription)")
    }
}
