import Foundation

/// Mock model fetcher for testing and development
/// Returns sample models with various context lengths
struct MockModelFetcher: ModelFetcher {
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo] {
    return [
      ModelInfo(
        id: "mock-gpt-4",
        name: "Mock GPT-4",
        inputContextLength: 128_000,
        outputContextLength: 4_000
      ),
      ModelInfo(
        id: "mock-claude-3-opus",
        name: "Mock Claude 3 Opus",
        inputContextLength: 200_000,
        outputContextLength: 4_000
      ),
      ModelInfo(
        id: "mock-gemini-pro",
        name: "Mock Gemini Pro",
        inputContextLength: 1_000_000,
        outputContextLength: 8_000
      ),
      ModelInfo(
        id: "mock-llama-3",
        name: "Mock Llama 3",
        inputContextLength: 128_000,
        outputContextLength: 8_000
      ),
      ModelInfo(
        id: "mock-mixtral",
        name: "Mock Mixtral",
        inputContextLength: 32_000,
        outputContextLength: 2_000
      )
    ]
  }
}
