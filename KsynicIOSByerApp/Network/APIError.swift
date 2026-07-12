import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverUnavailable
    case httpStatus(Int, String?)
    case decodingError(Error)
    case encodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .serverUnavailable:
            return "Сервер временно не работает. Попробуйте позже"
        case .httpStatus(let code, let message):
            if let message = message, !message.isEmpty {
                return message
            }
            return "Ошибка сервера: \(code)"
        case .decodingError:
            return "Ошибка обработки ответа сервера"
        case .encodingError:
            return "Ошибка подготовки запроса"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
