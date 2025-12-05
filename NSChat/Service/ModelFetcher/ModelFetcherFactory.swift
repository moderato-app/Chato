import Foundation

struct ModelFetcherFactory {
  static func createFetcher(for providerType: ProviderType) -> ModelFetcher {
    switch providerType {
    case .openAI:
      return OpenAIModelFetcher()
    case .openRouter:
      return OpenRouterModelFetcher()
    case .gemini:
      return GeminiModelFetcher()
    case .mock:
      return GenericStaticModelFetcher()
    case .anthropic,
         .groq,
         .mistral,
         .deepSeek,
         .perplexity,
         .stabilityAI,
         .deepL,
         .togetherAI,
         .replicate,
         .elevenLabs,
         .fal,
         .eachAI,
         .fireworksAI,
         .brave:
      return GenericStaticModelFetcher()
    }
  }
}

struct GenericStaticModelFetcher: ModelFetcher {
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo] {
    return []
  }
}

