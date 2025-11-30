import Foundation

struct ModelFetcherFactory {
  static func createFetcher(for providerType: ProviderType) -> ModelFetcher {
    switch providerType {
    case .openAI:
      return OpenAIModelFetcher()
    case .openRouter:
      return OpenRouterModelFetcher()
    case .mock:
      return GenericStaticModelFetcher()
    case .anthropic,
         .gemini,
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

