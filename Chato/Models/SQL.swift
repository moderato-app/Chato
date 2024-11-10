import Foundation
import SwiftData

extension ModelContext {
  func getChat(chatId: PersistentIdentifier) -> Chat? {
    let predicate = #Predicate<Chat> { $0.persistentModelID == chatId }
    let fetcher = FetchDescriptor<Chat>(predicate: predicate, fetchLimit: 1)
    do {
      let chat = try fetch(fetcher).first
      return chat
    } catch {
      print("error query chat, chat: \(chatId), err: \(error.localizedDescription)")
      return nil
    }
  }

  func getMessage(messageId: PersistentIdentifier) -> Message? {
    let predicate = #Predicate<Message> { $0.persistentModelID == messageId }
    let fetcher = FetchDescriptor<Message>(predicate: predicate, fetchLimit: 1)
    do {
      let message = try fetch(fetcher).first
      return message
    } catch {
      print("error query chat, chat: \(messageId), err: \(error.localizedDescription)")
      return nil
    }
  }

  func recentMessgagesEarlyOnTop(chatId: PersistentIdentifier, limit: Int) -> [Message] {
    let predicate = #Predicate<Message> { msg in
      msg.chat?.persistentModelID == chatId
    }
    var fetchDescriptor = FetchDescriptor<Message>(predicate: predicate, sortBy: [SortDescriptor(\Message.createdAt, order: .reverse)])
    fetchDescriptor.fetchLimit = limit
    return try! fetch(fetchDescriptor).sorted()
  }

  func findPromptById(promptId: PersistentIdentifier) -> Prompt? {
    let predicate = #Predicate<Prompt> { prompt in
      prompt.persistentModelID == promptId
    }
    let fetchDescriptor = FetchDescriptor<Prompt>(predicate: predicate)
    return try! fetch(fetchDescriptor).first
  }

  func promptCount() -> Int {
    let descriptor = FetchDescriptor<Prompt>(
      predicate: #Predicate { !$0.preset }
    )
    return (try? fetchCount(descriptor)) ?? 0
  }

  func nextPromptOrder() -> Int {
    let fetchDescriptor = FetchDescriptor<Prompt>(sortBy: [SortDescriptor(\Prompt.order, order: .reverse)], fetchLimit: 1)
    if let order = try! fetch(fetchDescriptor).first?.order {
      return order + 1
    } else {
      return 0
    }
  }

  func clearAll<T>(_ model: T.Type) where T: PersistentModel {
    do {
      let descriptor = FetchDescriptor<T>()
      if let chats = try? fetch(descriptor) {
        for chat in chats {
          delete(chat)
        }
      }
    }
  }

  func removePresetPrompts() throws {
    try delete(model: Prompt.self, where: #Predicate<Prompt> { $0.preset })
  }
}
