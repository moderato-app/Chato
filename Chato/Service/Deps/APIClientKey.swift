// Created for PopAI in 2024

import Foundation
import os
import AIProxy
import SwiftUI

// Define your custom environment key
struct OpenAIServiceKey: EnvironmentKey {
  static let defaultValue: OpenAIService = AIProxy.openAIDirectService(unprotectedAPIKey: "your-default-api-key")
}

// Add new AIClient environment key
struct AIClientKey: EnvironmentKey {
  static let defaultValue: AIClientProtocol = AIClient.init(endpoint: "", apiKey: "")
}

// Extend EnvironmentValues to include both keys
extension EnvironmentValues {
  var openAIService: OpenAIService {
    get {
      self[OpenAIServiceKey.self]
    }
    set {
      self[OpenAIServiceKey.self] = newValue
    }
  }

  var aiClient: AIClientProtocol {
    get {
      self[AIClientKey.self]
    }
    set {
      self[AIClientKey.self] = newValue
    }
  }
}

class OpenAIServiceProvider: ObservableObject {
  let service: OpenAIService

  init(apiKey: String, endpint: String? = nil) {
    if let endpint {
      do {
        let res = try parseURL(endpint)
        self.service = AIProxy.openAIDirectService(unprotectedAPIKey: apiKey, baseURL: res.base)
      } catch {
        AppLogger.logError(.from(
          error: error,
          operation: "Parse URL",
          component: "OpenAIServiceProvider",
          userMessage: nil
        ))
        self.service = AIProxy.openAIDirectService(unprotectedAPIKey: apiKey)
      }
    } else {
      self.service = AIProxy.openAIDirectService(unprotectedAPIKey: apiKey)
    }
  }
}

// Add new AIClientProvider if needed
class AIClientProvider: ObservableObject {
  let service: AIClientProtocol

  init(endpoint: String, apiKey: String, timeout: TimeInterval = 120) {
    self.service = AIClient(endpoint: endpoint, apiKey: apiKey, timeout: timeout)
  }
}
