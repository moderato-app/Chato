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
  
  init(message: String, role: MessageRole, chat: Chat? = nil, createdAt: Date, updatedAt: Date, status: MessageStatus, errorInfo: String, errorType: MessageErrorType) {
    self.message = message
    self.role = role
    self.chat = chat
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.status = status
    self.errorInfo = errorInfo
    self.errorType = errorType
  }
  
  func clone() -> Message {
    return .init(message: self.message, role: self.role, createdAt: self.createdAt, updatedAt: self.updatedAt, status: self.status, errorInfo: self.errorInfo, errorType: self.errorType)
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
  // temperature  number or null  Optional  Defaults to 1
  // What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  // We generally recommend altering this or top_p but not both.
  @Attribute(originalName: "temperature") var temperature: Double = 1
  // presence_penalty number or null  Optional  Defaults to 0
  // Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
  @Attribute(originalName: "presence_penalty") var presencePenalty: Double = 0
  // frequency_penalty  number or null  Optional  Defaults to 0
//  Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
  @Attribute(originalName: "frequency_penalty") var frequencyPenalty: Double = 0
  // An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
      
  init(model: String = defaultGPTModel.value, contextLength: Int = 2, prompt: Prompt? = nil) {
    self.model = model
    self.contextLength = contextLength
    self.prompt = prompt
  }
  
  init(model: String, contextLength: Int, prompt: Prompt? = nil, temperature: Double, presencePenalty: Double, frequencyPenalty: Double) {
    self.model = model
    self.contextLength = contextLength
    self.prompt = prompt
    self.temperature = temperature
    self.presencePenalty = presencePenalty
    self.frequencyPenalty = frequencyPenalty
  }
  
  @Transient
  var isBestModel: Bool {
    self.model.isBestModel
  }

  @Transient
  var maybeTemperature: Double? {
    doubleEqual(self.temperature, 1.0) ? nil : self.temperature
  }

  @Transient
  var maybePresencePenalty: Double? {
    doubleEqual(self.presencePenalty, 0.0) ? nil : self.presencePenalty
  }

  @Transient
  var maybeFrequencyPenalty: Double? {
    doubleEqual(self.frequencyPenalty, 0.0) ? nil : self.frequencyPenalty
  }

  func clone() -> ChatOption {
    return ChatOption(model: self.model, contextLength: self.contextLength, prompt: self.prompt, temperature: self.temperature, presencePenalty: self.presencePenalty, frequencyPenalty: self.frequencyPenalty)
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
