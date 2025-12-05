import Foundation
import os

/// Factory for creating streaming services based on provider type
struct ChatStreamingServiceFactory {
  /// Create a streaming service for the given provider type
  /// - Parameter providerType: The type of provider
  /// - Returns: A service conforming to ChatStreamingServiceProtocol
  static func createService(for providerType: ProviderType) -> ChatStreamingServiceProtocol {
    switch providerType {
    case .mock:
      return MockStreamingService()
    case .openAI:
      return OpenAIStreamingService()
    case .openRouter:
      return OpenRouterStreamingService()
    case .gemini:
      return GeminiStreamingService()
    default:
      // For unsupported providers, return mock as fallback
      AppLogger.error.error(
        "[ChatStreamingServiceFactory] ⚠️ Unsupported provider type: \(providerType.displayName), using Mock service"
      )
      return MockStreamingService()
    }
  }
}

