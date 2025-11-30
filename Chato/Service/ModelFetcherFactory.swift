// Created for Chato in 2025

import Foundation

struct ModelFetcherFactory {
  static func createFetcher(for providerType: ProviderType) -> ModelFetcher {
    switch providerType {
    case .openAI:
      return OpenAIModelFetcher()
    case .openRouter:
      return OpenRouterModelFetcher()
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
      return GenericStaticModelFetcher(providerType: providerType)
    }
  }
}

struct GenericStaticModelFetcher: ModelFetcher {
  let providerType: ProviderType
  
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo] {
    return []
  }
}

