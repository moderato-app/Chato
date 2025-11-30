// Created for Chato in 2025

import Foundation
import SwiftData

@Model
final class ModelEntity {
  @Attribute(originalName: "modelId") var modelId: String = ""
  @Attribute(originalName: "modelName") var modelName: String?
  @Attribute(originalName: "contextLength") var contextLength: Int?
  @Attribute(originalName: "favorited") var favorited: Bool
  @Attribute(originalName: "isCustom") var isCustom: Bool
  @Attribute(originalName: "createdAt") var createdAt: Date
  @Relationship(originalName: "provider")
  var provider: Provider
  @Relationship(deleteRule: .nullify, originalName: "chatOptions", inverse: \ChatOption.model)
  var chatOptions: [ChatOption]
  @Relationship(deleteRule: .cascade, originalName: "usedModels", inverse: \UsedModel.model)
  var usedModels: [UsedModel]

  init(
    provider: Provider,
    modelId: String,
    modelName: String? = nil,
    contextLength: Int? = nil,
    favorited: Bool = false,
    isCustom: Bool = false,
  ) {
    self.provider = provider
    self.modelId = modelId
    self.modelName = modelName
    self.contextLength = contextLength
    self.favorited = favorited
    self.isCustom = isCustom
    self.createdAt = .now
    self.chatOptions = []
    self.usedModels = []
  }

  var resolvedName: String {
    modelName ?? modelId
  }
}

extension Array where Element == ModelEntity {
  func groupedByProvider() -> [(provider: Provider, models: [ModelEntity])] {
    let grouped = Dictionary(grouping: self) { $0.provider }
    return grouped.compactMap { provider, value in
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
