import Foundation
import SwiftData

@Model
final class Provider {
  @Attribute(originalName: "alias") var alias: String = ""
  @Attribute(originalName: "apiKey") var apiKey: String = ""
  @Attribute(originalName: "enabled") var enabled: Bool
  @Attribute(originalName: "endpoint") var endpoint: String = ""
  @Attribute(originalName: "type") var type: ProviderType
  @Attribute(originalName: "createdAt") var createdAt: Date
  
  @Relationship(deleteRule: .cascade, originalName: "models",inverse: \ModelEntity.provider)
  var models: [ModelEntity]
  
  init(
    type: ProviderType,
    alias: String = "",
    apiKey: String = "",
    endpoint: String = "",
    enabled: Bool = true
  ) {
    self.type = type
    self.alias = alias
    self.apiKey = apiKey
    self.endpoint = endpoint
    self.enabled = enabled
    self.createdAt = Date()
    self.models = []
  }
  
  var displayName: String {
    if !alias.isEmpty {
      return alias
    }
    return type.displayName
  }
  
  var allModelsSorted: [ModelEntity] {
    ModelEntity.smartSort(models)
  }
}


