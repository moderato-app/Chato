import Foundation
import SwiftData

@Model
final class UsedModel {
  @Relationship(originalName: "option")
  var model: ModelEntity
  @Attribute(originalName: "createdAt") var createdAt: Date
  
  init(model: ModelEntity, createdAt: Date = .now) {
    self.model = model
    self.createdAt = createdAt
  }
}
