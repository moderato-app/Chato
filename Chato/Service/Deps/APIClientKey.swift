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

  init(apiKey: String, baseUrl: String? = nil) {
    let conf = URLSessionConfiguration.default
    conf.timeoutIntervalForRequest = 120

    if let baseUrl{
      self.service = OpenAIServiceFactory.service(apiKey: apiKey, configuration: conf, overrideBaseURL: baseUrl)
    }else{
      self.service = OpenAIServiceFactory.service(apiKey: apiKey, configuration: conf)
    }
  }
}
