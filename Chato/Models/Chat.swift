import Foundation
import SwiftData

@Model
final class Chat: NewAtFront {
  @Attribute(originalName: "name") var name: String
  @Relationship(deleteRule: .cascade, originalName: "messages", inverse: \Message.chat)
  var messages = [Message]()
  @Attribute(originalName: "createdAt") var createdAt: Date
  @Attribute(originalName: "updatedAt") var updatedAt: Date
  @Attribute(originalName: "order") var order: Int
  @Attribute(originalName: "favorited") var favorited: Bool
  @Attribute(originalName: "input") var input: String
  @Relationship(deleteRule: .cascade, originalName: "option")
  var option: ChatOption

  @Transient
  var isBestModel: Bool {
    self.option.isBestModel
  }

  init(name: String, messages: [Message] = [Message](), option: ChatOption = ChatOption()) {
    self.name = name
    self.messages = messages
    self.createdAt = Date.now
    self.updatedAt = Date.now
    self.favorited = false
    self.input = ""
    self.option = option
    self.order = Int(Date().timeIntervalSince1970 * 1000)
  }

  init(name: String, messages: [Message] = [Message](), createdAt: Date, updatedAt: Date,
       favorited: Bool, input: String, option: ChatOption)
  {
    self.name = name
    self.messages = messages
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.order = Int(Date().timeIntervalSince1970 * 1000)
    self.favorited = favorited
    self.input = input
    self.option = option
  }

  func clone() -> Chat {
    let msgs = self.messages.map { $0.clone() }
    let chat = Chat(name: self.name + " copy", messages: msgs, createdAt: .now, updatedAt: .now, favorited: self.favorited, input: self.input, option: self.option.clone())
    return chat
  }
}
