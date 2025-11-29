// Created for Chato in 2025

import Foundation
import SwiftData

@Model
final class ModelEntity {
  @Attribute(.unique, originalName: "id") var id: String
  @Attribute(originalName: "name") var name: String?
  @Attribute(originalName: "contextLength") var contextLength: Int?
  @Attribute(originalName: "favorited") var favorited: Bool
  @Attribute(originalName: "isCustom") var isCustom: Bool
  @Attribute(originalName: "createdAt") var createdAt: Date
  
  var provider: Provider?
  
  init(
    id: String,
    name: String? = nil,
    contextLength: Int? = nil,
    favorited: Bool = false,
    isCustom: Bool = false,
    provider: Provider? = nil
  ) {
    self.id = id
    self.name = name
    self.contextLength = contextLength
    self.favorited = favorited
    self.isCustom = isCustom
    self.createdAt = Date()
    self.provider = provider
  }
  
  var resolvedName: String {
    name ?? id
  }
  
  var displayName: String {
    if let provider = provider {
      return "\(provider.displayName) / \(resolvedName)"
    }
    return resolvedName
  }
}

extension Array where Element == ModelEntity {
  func groupedByProvider() -> [(provider: Provider, models: [ModelEntity])] {
    let grouped = Dictionary(grouping: self) { $0.provider }
    return grouped.compactMap { key, value in
      guard let provider = key else { return nil }
      let sortedModels = value.sorted { model1, model2 in
        if model1.favorited != model2.favorited {
          return model1.favorited
        }
        if model1.isCustom != model2.isCustom {
          return model1.isCustom
        }
        return model1.resolvedName < model2.resolvedName
      }
      return (provider: provider, models: sortedModels)
    }.sorted { $0.provider.displayName < $1.provider.displayName }
  }
  
  var favorited: [ModelEntity] {
    filter { $0.favorited }.sorted { model1, model2 in
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


