import SwiftData
import SwiftUI

struct ChatRowView: View {
  @Environment(\.modelContext) private var modelContext

  var chat: Chat
  @State private var message: Message?

  func loadLatestMsg() {
    let chatId = chat.persistentModelID
    let predicate = #Predicate<Message> { msg in
      msg.chat?.persistentModelID == chatId
    }
    let fetcher = FetchDescriptor<Message>(predicate: predicate, sortBy: [SortDescriptor(\Message.createdAt, order: .reverse)], fetchLimit: 1)
    do {
      message = try modelContext.fetch(fetcher).first
    } catch {
      print("message = try modelContext.fetch(fetcher).first :\(error)")
    }
  }

  var body: some View {
    // let _ = Self.printChagesWhenDebug()
    VStack(alignment: .leading) {
      HStack {
        Text(chat.name)
          .font(.headline)
        Spacer()
        Text(formatAgo(from: chat.updatedAt))
          .foregroundColor(.secondary)
          .font(.footnote)
      }
      HStack {
        if chat.input.isMeaningful {
          Text(Image(systemName: "pencil.and.outline")).foregroundStyle(.primary) + Text(" " + chat.input.meaningfulString)
        } else {
          if let message {
            let sender = message.role == .user ? "You: " : ""
            Text(sender + message.message + String(repeating: " ", count: 50))
          } else {
            Text(String(repeating: " ", count: 50))
          }
        }
      }
      .foregroundColor(.secondary)
      .lineLimit(2)
    }
    .onAppear {
      print("loadLatestMsg()")
      loadLatestMsg()
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    NavigationStack {
      List {
        ChatRowView(chat: ChatSample.manyMessages)
        ChatRowView(chat: ChatSample.emptyMessage)
      }
    }
  }
}
