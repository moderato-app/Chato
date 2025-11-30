// Created for Chato in 2025

import Foundation

/// Chat message structure for API requests
struct ChatMessage {
  enum MessageType {
    case user
    case assistant
    case system
  }
  
  let type: MessageType
  let content: String
}

/// Streaming service configuration
struct StreamingServiceConfig {
  /// API Key (OpenAI, OpenRouter, etc. need this)
  let apiKey: String?
  
  /// Model ID (OpenAI, OpenRouter, etc. need this)
  let modelID: String?
  
  /// Custom endpoint URL (OpenAI supports this)
  let endpoint: String?
  
  /// Word count for Mock provider
  let wordCount: Int?
  
  /// Create config for OpenAI
  static func openAI(apiKey: String, modelID: String, endpoint: String?) -> StreamingServiceConfig {
    return StreamingServiceConfig(
      apiKey: apiKey,
      modelID: modelID,
      endpoint: endpoint,
      wordCount: nil
    )
  }
  
  /// Create config for OpenRouter
  static func openRouter(apiKey: String, modelID: String) -> StreamingServiceConfig {
    return StreamingServiceConfig(
      apiKey: apiKey,
      modelID: modelID,
      endpoint: nil,
      wordCount: nil
    )
  }
  
  /// Create config for Mock
  static func mock(wordCount: Int = 50) -> StreamingServiceConfig {
    return StreamingServiceConfig(
      apiKey: nil,
      modelID: nil,
      endpoint: nil,
      wordCount: wordCount
    )
  }
}

/// Protocol for streaming chat completion services
/// All provider implementations must conform to this protocol
protocol ChatStreamingServiceProtocol {
  /// Send streaming chat completion request
  /// - Parameters:
  ///   - messages: Message history
  ///   - config: Service configuration (API key, model ID, etc.)
  ///   - onStart: Callback when streaming starts
  ///   - onDelta: Callback for each delta text chunk (deltaText, fullText)
  ///   - onComplete: Callback when streaming completes
  ///   - onError: Callback when an error occurs
  func streamChatCompletion(
    messages: [ChatMessage],
    config: StreamingServiceConfig,
    onStart: @escaping () -> Void,
    onDelta: @escaping (String, String) -> Void,
    onComplete: @escaping (String) -> Void,
    onError: @escaping (Error) -> Void
  )
}

