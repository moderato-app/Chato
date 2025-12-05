import Foundation
import os

/// Error streaming service for unsupported providers
/// Immediately calls onError with a message indicating the provider is not supported
class ErrorStreamingService: ChatStreamingServiceProtocol {
  let providerType: ProviderType
  
  init(providerType: ProviderType) {
    self.providerType = providerType
  }
  
  func streamChatCompletion(
    messages: [ChatMessage],
    config: StreamingServiceConfig,
    onStart: @escaping () -> Void,
    onDelta: @escaping (String, String) -> Void,
    onComplete: @escaping (String) -> Void,
    onError: @escaping (Error) -> Void
  ) {
    let errorMessage = "Provider \(providerType.displayName) is not supported for chat streaming"
    
    AppLogger.error.error(
      "[ErrorStreamingService] ❌ Unsupported provider: \(self.providerType.displayName)"
    )
    
    // Call onStart immediately
    onStart()
    
    // Create and report error
    let error = NSError(
      domain: "ErrorStreamingService",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: errorMessage]
    )
    
    onError(error)
  }
}
