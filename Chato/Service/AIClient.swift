// Created for Chato in 2024

import Foundation

protocol AIClientProtocol {
  func fetchModels() async throws -> [ModelModel]
}

class AIClient: AIClientProtocol {
  private let endpoint: String
  private let apiKey: String
  private let timeout: TimeInterval

  init(endpoint: String, apiKey: String, timeout: TimeInterval = 120) {
    self.endpoint = endpoint
    self.apiKey = apiKey
    self.timeout = timeout
  }

  func fetchModels() async throws -> [ModelModel] {
    let aiModels = try await models(endpoint: endpoint, apiKey: apiKey, timeout: timeout)
    return aiModels.map { aiModel in
      let model = ModelModel(modelId: aiModel.id, name: aiModel.name)
      model.info = aiModel.description
      model.contextLength = aiModel.contextLength
      return model
    }
  }
}

// Move existing private functions and models under AIClient
private extension AIClient {
  func models(endpoint: String, apiKey: String, timeout: TimeInterval) async throws -> [AIModel] {
    let url = URL(string: "\(endpoint)/v1/models")!

    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = timeout

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
    }

    guard (200 ... 299).contains(httpResponse.statusCode) else {
      let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorBody])
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let res = try decoder.decode(ModelResponse.self, from: data)
    let models =  res.data
    return models
  }
}

// Keep existing model structs
struct ModelResponse: Codable {
  let data: [AIModel]
}

struct AIModel: Codable {
  let id: String
  let name: String?
  let description: String?
  let contextLength: Int?

  enum CodingKeys: String, CodingKey {
    case id, name, description
    case contextLength
  }
}
