import Foundation
import SwiftData

enum WebSearchContextSize: String, CaseIterable, Codable {
  case low = "Low"
  case medium = "Medium"
  case high = "High"
  
  var title: String {
    rawValue
  }
}

@Model
final class WebSearch {
  @Attribute(originalName: "enabled")
  var enabled: Bool
  @Attribute(originalName: "context_size")
  var contextSize: WebSearchContextSize
  
  init(enabled: Bool = false, contextSize: WebSearchContextSize = .low) {
    self.enabled = enabled
    self.contextSize = contextSize
  }
  
  func clone() -> WebSearch {
    WebSearch(enabled: enabled, contextSize: contextSize)
  }
}
