import SwiftData
import SwiftUI

struct CaChatRowPreview: View {
  var chatId: PersistentIdentifier

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    HStack {
      if let item = ChatRowCache.shared.get(chatId) {
        InnerChatRowView(item: item)
      } else {
        VStack{
          Text(" ")
          Text(" ")
          Text(" ")
        }
      }
    }
  }
}

#Preview {
  CaChatRowPreview(chatId: ChatSample.manyMessages.persistentModelID)
}
