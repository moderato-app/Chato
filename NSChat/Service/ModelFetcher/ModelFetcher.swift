import Foundation

protocol ModelFetcher {
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo]
}

struct ModelInfo: Sendable, Equatable {
  let id: String
  let name: String
  let inputContextLength: Int?
  let outputContextLength: Int?
  
  init(id: String, name: String? = nil, inputContextLength: Int? = nil, outputContextLength: Int? = nil) {
    self.id = id
    self.name = name ?? id
    self.inputContextLength = inputContextLength
    self.outputContextLength = outputContextLength
  }
}

enum ModelFetchError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case decodingError(String)
  case apiError(String)
  case networkError(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .invalidResponse:
      return "Invalid response from server"
    case .decodingError(let message):
      return "Decoding error: \(message)"
    case .apiError(let message):
      return "API error: \(message)"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    }
  }
}

