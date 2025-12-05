import Foundation

extension ProviderType {
  var isSupportedByNSChat: Bool {
    switch self {
    case .openAI, .openRouter, .gemini, .mock:
      return true
    default:
      return false
    }
  }

  func createFetcher() -> ModelFetcher {
    switch self {
    case .openAI:
      return OpenAIModelFetcher()
    case .openRouter:
      return OpenRouterModelFetcher()
    case .gemini:
      return GeminiModelFetcher()
    case .mock:
      return MockModelFetcher()
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
      return ErrorModelFetcher(providerType: self)
    }
  }
}
