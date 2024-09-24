import Foundation
import SwiftData

struct ChatRowCacheItem {
  let name: String
  let updatedAt: Date?
  let input: String
  let role: Message.MessageRole?
  let text: String?
}

final class ChatRowCache {
  static let shared = ChatRowCache()
  private var cache: [PersistentIdentifier: ChatRowCacheItem] = [:]
  private let queue = DispatchQueue(label: "StringCacheQueue")

  private init() {}

  func get(_ key: PersistentIdentifier) -> ChatRowCacheItem? {
    return queue.sync {
      cache[key]
    }
  }

  func set(_ key: PersistentIdentifier, _ value: ChatRowCacheItem) {
    queue.sync {
      cache[key] = value
    }
  }

  func remove(_ key: PersistentIdentifier) {
    _ = queue.sync {
      cache.removeValue(forKey: key)
    }
  }
}
