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

  init(name: String, messages: [Message] = [Message](), option: ChatOption = ChatOption(), order: Int) {
    self.name = name
    self.messages = messages
    self.createdAt = Date.now
    self.updatedAt = Date.now
    self.favorited = false
    self.input = ""
    self.option = option
    self.order = order
  }
}
  
@Model
final class Message: Comparable {
  @Attribute(originalName: "message") var message: String
  @Attribute(originalName: "role") var role: MessageRole
  @Attribute(originalName: "chat") var chat: Chat?
  @Attribute(originalName: "createdAt") var createdAt: Date
  @Attribute(originalName: "updatedAt") var updatedAt: Date
  @Attribute(originalName: "status") var status: MessageStatus
  @Attribute(originalName: "errorInfo") var errorInfo: String
  @Attribute(originalName: "errorType") var errorType: MessageErrorType

  init(_ message: String, _ role: MessageRole, _ status: MessageStatus, errorInfo: String = "", errorType: MessageErrorType = .unknown) {
    self.message = message
    self.role = role
    self.createdAt = Date.now
    self.updatedAt = Date.now
    self.status = status
    self.errorInfo = errorInfo
    self.errorType = errorType
      
    if role == .assistant && (status == .sending || status == .sent) ||
      role == .user && (status == .thinking || status == .typing || status == .received)
    {
      fatalError("invalid status")
    }
  }
    
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.createdAt < rhs.createdAt
  }
    
  // user
  func onSent() {
    switch self.status {
    case .sending:
      self.status = .sent
      self.updatedAt = Date.now
    case .sent, .thinking, .typing, .received, .error:
      print("Error: onSent is invalid, current status: \(self.status.rawValue)")
    }
  }
    
  // assistant
  func onTyping(text: String) {
    switch self.status {
    case .thinking, .typing:
      self.status = .typing
      self.message += text
      self.updatedAt = Date.now
    case .sending, .sent, .received, .error:
      print("Error: onTyping is invalid, current status: \(self.status.rawValue)")
    }
  }
    
  func onEOF(text: String) {
    switch self.status {
    case .thinking, .typing:
      self.status = .received
      self.message += text
      self.updatedAt = Date.now
    case .sending, .sent, .received, .error:
      print("Error: onEOF is invalid, current status: \(self.status.rawValue)")
    }
  }
    
  func onError(_ errorInfo: String, _ errorType: MessageErrorType) {
    switch self.status {
    case .sending, .thinking, .typing:
      self.status = .error
      self.errorInfo += errorInfo
      self.errorType = errorType
      self.updatedAt = Date.now
    case .error, .received, .sent:
      print("Error: onError is invalid, current status: \(self.status.rawValue)")
    }
  }
}
  
@Model
final class ChatOption {
  @Attribute(originalName: "model") var model: String
  @Attribute(originalName: "context_length") var contextLength: Int
  @Relationship(originalName: "prompt") var prompt: Prompt?
    
  @Transient
  var isBestModel: Bool {
    self.model.isBestModel
  }
    
  init(model: String = defaultGPTModel.value, contextLength: Int = 2, prompt: Prompt? = nil) {
    self.model = model
    self.contextLength = contextLength
    self.prompt = prompt
  }
    
  func clone() -> ChatOption {
    return ChatOption(model: self.model, contextLength: self.contextLength, prompt: self.prompt)
  }
}

extension Message {
  enum MessageRole: String, CaseIterable, Codable {
    case assistant, system, user
    
    var senderName: String {
      self == .user ? "You" : self.rawValue.capitalized
    }
  }

  enum MessageStatus: String, CaseIterable, Codable {
    case sending, sent, thinking, typing, received, error
  }
  
  enum MessageErrorType: String, CaseIterable, Codable {
    case unknown, apiKey, network
  }
}
