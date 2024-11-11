// Created for PopAI in 2024

import Foundation
import SwiftOpenAI

import SwiftUI

// Define your custom environment key
struct OpenAIServiceKey: EnvironmentKey {
  static let defaultValue: OpenAIService = OpenAIServiceFactory.service(apiKey: "your-default-api-key")
}

// Extend EnvironmentValues to include your custom key
extension EnvironmentValues {
  var openAIService: OpenAIService {
    get {
      self[OpenAIServiceKey.self]
    }
    set {
      self[OpenAIServiceKey.self] = newValue
    }
  }
}

class OpenAIServiceProvider: ObservableObject {
  let service: OpenAIService

  init(apiKey: String, endpint: String? = nil, timeout: TimeInterval = 120) {
    let conf = URLSessionConfiguration.default
    conf.timeoutIntervalForRequest = timeout

    if let endpint {
      do {
        let res = try parseURL(endpint)
        self.service = OpenAIServiceFactory.service(apiKey: apiKey, configuration: conf, overrideBaseURL: res.base, proxyPath: res.path)
      } catch {
        print("let res = try parseURL(endpint): \(error)")
        self.service = OpenAIServiceFactory.service(apiKey: apiKey, configuration: conf)
      }
    } else {
      self.service = OpenAIServiceFactory.service(apiKey: apiKey, configuration: conf)
    }
  }
}
