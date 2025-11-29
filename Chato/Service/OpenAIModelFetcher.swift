// Created for Chato in 2025

import Foundation

struct OpenAIModelFetcher: ModelFetcher {
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo] {
    let urlString = endpoint ?? "https://api.openai.com/v1/models"
    
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
    
    struct OpenAIModelsResponse: Codable {
      struct ModelObject: Codable {
        let id: String
      }
      let data: [ModelObject]
    }
    
    let decoder = JSONDecoder()
    guard let modelsResponse = try? decoder.decode(OpenAIModelsResponse.self, from: data) else {
      throw ModelFetchError.decodingError("Failed to decode OpenAI models response")
    }
    
    let chatModels = modelsResponse.data.filter { model in
      model.id.contains("gpt") ||
      model.id.contains("o1") ||
      model.id.contains("o3")
    }
    
    return chatModels.map { ModelInfo(id: $0.id, name: $0.id) }
  }
}

