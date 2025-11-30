import Foundation
import SwiftData

@Model
final class Prompt: Comparable, Decodable, NewAtFront {
  enum CodingKeys: CodingKey {
    case name, messages, languageCode
  }

  @Attribute(originalName: "name") var name: String
  @Relationship(deleteRule: .cascade, originalName: "messages") var messages: [PromptMessage]
  @Relationship(deleteRule: .nullify, originalName: "chatOptions", inverse: \ChatOption.prompt) var chatOptions: [ChatOption]

  @Attribute(originalName: "languageCode") var languageCode: String
  @Attribute(originalName: "preset") var preset: Bool
  @Attribute(originalName: "favorited") var favorited: Bool
  @Attribute(originalName: "createdAt") var createdAt: Date
  @Attribute(originalName: "updatedAt") var updatedAt: Date
  @Attribute(originalName: "order") var order: Int

  init(name: String,
       messages: [PromptMessage] = [PromptMessage](),
       chatOptions: [ChatOption] = [ChatOption](),
       languageCode: String = "en_US",
       createdAt: Date = .now,
       updatedAt: Date = .now,
       favorited: Bool = false,
       preset: Bool = false,
       order: Int)
  {
    self.name = name
    self.messages = messages
    self.chatOptions = chatOptions
    self.languageCode = languageCode
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.favorited = favorited
    self.preset = preset
    self.order = order
  }

  static func < (lhs: Prompt, rhs: Prompt) -> Bool {
    return lhs.order > rhs.order
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.messages = try container.decode([PromptMessage].self, forKey: .messages)
    self.chatOptions = []
    self.languageCode = try container.decode(String.self, forKey: .languageCode)
    self.createdAt = Date.distantPast
    self.updatedAt = Date.distantPast
    self.favorited = false
    self.preset = true
    self.order = 0
  }

  func copy(order: Int) -> Prompt {
    return Prompt(
      name: self.name + " copy",
      messages: self.messages.map { it in it.clone() },
      createdAt: Date.now,
      updatedAt: Date.now,
      favorited: self.favorited,
      preset: false,
      order: order
    )
  }
}

@Model
final class PromptMessage: Comparable, Decodable, NewAtTail {
  enum CodingKeys: CodingKey {
    case content, role, order
  }

  @Attribute(originalName: "content") var content: String
  @Attribute(originalName: "role") var role: Message.MessageRole
  @Attribute(originalName: "order") var order: Int

  @Transient var uuid = UUID().uuidString

  init(content: String, role: Message.MessageRole = .system, order: Int) {
    self.content = content
    self.role = role
    self.order = order
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.content = try container.decode(String.self, forKey: .content)
    self.role = try container.decode(Message.MessageRole.self, forKey: .role)
    self.order = try container.decode(Int.self, forKey: .order)
  }

  static func < (lhs: PromptMessage, rhs: PromptMessage) -> Bool {
    return lhs.order < rhs.order
  }

  func clone() -> PromptMessage {
    return PromptMessage(content: self.content, role: self.role, order: self.order)
  }
}
