import Foundation
import SwiftData

extension ModelContext {
  var sqliteCommand: String {
    if let url = container.configurations.first?.url.path(percentEncoded: false) {
      "sqlite3 \"\(url)\""
    } else {
      "No SQLite database found."
    }
  }
}

protocol NewAtFront: AnyObject {
  var order: Int { get set }
}

protocol NewAtTail: AnyObject {
  var order: Int { get set }
}

extension Array where Element: NewAtFront {
  func reIndex() {
    for (index, item) in reversed().enumerated() {
      item.order = index
    }
  }
}

extension Array where Element: NewAtTail {
  func reIndex() {
    for (index, item) in enumerated() {
      item.order = index
    }
  }
}

extension FetchDescriptor {
  init (predicate: Predicate<T>? = nil, sortBy: [SortDescriptor<T>] = [], fetchLimit: Int){
    self.init(predicate: predicate, sortBy: sortBy)
    self.fetchLimit = fetchLimit
  }
}
