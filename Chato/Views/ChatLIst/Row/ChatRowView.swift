import SwiftData
import SwiftUI

struct ChatRowView: View {
  var chat: Chat
  @Query private var messages: [Message]

  init(_ chat: Chat) {
    self.chat = chat
    let chatId = chat.persistentModelID
    let predicate = #Predicate<Message> { msg in
      msg.chat?.persistentModelID == chatId
    }
    let fetcher = FetchDescriptor<Message>(predicate: predicate, sortBy: [SortDescriptor(\Message.createdAt, order: .reverse)], fetchLimit: 4)
    _messages = Query(fetcher)
  }

  var item: ChatRowCacheItem {
    //let _ = Self.printChagesWhenDebug()
    let msg = messages.first(where: { !$0.message.isEmpty })
    let item = ChatRowCacheItem(name: chat.name,
                                updatedAt: msg?.createdAt,
                                input: chat.input,
                                role: msg?.role,
                                text: msg?.message)
    return item
  }

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    InnerChatRowView(item: item)
      .onAppear {
        ChatRowCache.shared.set(chat.persistentModelID, item)
      }
  }
}

struct InnerChatRowView: View {
  var item: ChatRowCacheItem

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    VStack(alignment: .leading) {
      HStack {
        Text(item.name)
          .font(.headline)
        Spacer()
        if let up = item.updatedAt {
          Text(formatAgo(from: up))
            .foregroundColor(.secondary)
            .font(.footnote)
        }
      }
      HStack {
        if item.input.isMeaningful {
          Text(Image(systemName: "pencil.and.outline")).foregroundStyle(.primary) + Text(" " + item.input.meaningfulString)
        } else {
          if let role = item.role, let text = item.text {
            let sender = role == .user ? "You: " : ""
            Text(sender + text + String(repeating: " ", count: 50))
          } else {
            Text(String(repeating: " ", count: 50))
          }
        }
      }
      .foregroundColor(.secondary)
      .lineLimit(2)
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    NavigationStack {
      List {
        ChatRowView(ChatSample.manyMessages)
        ChatRowView(ChatSample.emptyMessage)
      }
    }
  }
}
