import Foundation
import os

/// Error model fetcher for unsupported providers
/// Throws an error indicating the provider is not supported
struct ErrorModelFetcher: ModelFetcher {
  let providerType: ProviderType
  
  func fetchModels(apiKey: String, endpoint: String?) async throws -> [ModelInfo] {
    let errorMessage = "Provider \(providerType.displayName) is not supported for model fetching"
    
    AppLogger.error.error(
      "[ErrorModelFetcher] ❌ Unsupported provider: \(providerType.displayName)"
    )
    
    throw ModelFetchError.apiError(errorMessage)
  }
}
