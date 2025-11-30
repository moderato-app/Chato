// Created for Chato in 2025

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
  
  var iconName: String {
    type.iconName
  }
  
  var favoritedModels: [ModelEntity] {
    models.filter { $0.favorited }.sorted { model1, model2 in
      if model1.favorited != model2.favorited {
        return model1.favorited
      }
      if model1.isCustom != model2.isCustom {
        return model1.isCustom
      }
      return model1.resolvedName < model2.resolvedName
    }
  }
  
  var nonFavoritedModels: [ModelEntity] {
    models.filter { !$0.favorited }.sorted { model1, model2 in
      if model1.isCustom != model2.isCustom {
        return model1.isCustom
      }
      return model1.resolvedName < model2.resolvedName
    }
  }
  
  var allModelsSorted: [ModelEntity] {
    models.sorted { model1, model2 in
      if model1.favorited != model2.favorited {
        return model1.favorited
      }
      if model1.isCustom != model2.isCustom {
        return model1.isCustom
      }
      return model1.resolvedName < model2.resolvedName
    }
  }
}


