// Created for Chato in 2025

import Foundation

struct OpenRouterModelFetcher: ModelFetcher {
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo] {
    let urlString = endpoint ?? "https://openrouter.ai/api/v1/models"
    
    guard let url = URL(string: urlString) else {
      throw ModelFetchError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = 30
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw ModelFetchError.invalidResponse
    }
    
    guard httpResponse.statusCode == 200 else {
      throw ModelFetchError.apiError("HTTP \(httpResponse.statusCode)")
    }
    
    struct OpenRouterModelsResponse: Codable {
      struct ModelObject: Codable {
        let id: String
        let name: String?
      }
      let data: [ModelObject]
    }
    
    let decoder = JSONDecoder()
    guard let modelsResponse = try? decoder.decode(OpenRouterModelsResponse.self, from: data) else {
      throw ModelFetchError.decodingError("Failed to decode OpenRouter models response")
    }
    
    return modelsResponse.data.map { ModelInfo(id: $0.id, name: $0.name ?? $0.id) }
  }
}

