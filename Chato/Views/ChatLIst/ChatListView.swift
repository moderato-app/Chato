import SwiftData
import SwiftUI

struct ChatListView: View {
  static let sortOrder = [SortDescriptor(\Chat.order, order: .reverse)]

  @Environment(\.colorScheme) var colorScheme
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Chat.createdAt) private var chats: [Chat]
  @State var isDeleteConfirmPresented: Bool = false
  @State var chatToDelete: Chat?
  @State var uiState = UIState.shared

  @State private var selection: Chat?

  @Namespace() var namespace

  init(_ searchString: String) {
    _chats = Query(filter: #Predicate {
      if searchString.isEmpty {
        return true
      } else {
        return $0.name.localizedStandardContains(searchString)
      }
    }, sort: Self.sortOrder)
  }

  var body: some View {
    VStack {
      List {
        Color.clear
          .frame(height: 0)
          .listRowSpacing(5)
          .listRowBackground(Rectangle().fill(.clear))
          .listRowSeparator(.hidden)
        ForEach(chats, id: \.self) { chat in
          NavigationLink(value: chat) {
            if uiState.inChatView {
              CaChatRowPreview(chatId: chat.persistentModelID)
            } else {
              ChatRowView(chat)
            }
          }
          .animation(.default, value: uiState.inChatView)
          .lovelyRow()
          .swipeActions {
            // Avoid using the `chat` variable in the confirm dialog. Swipe actions seem to re-calculate
            // the list, which might delete the wrong chat.
            // Don't use role = .destructive, or confirmation dialog animation becomes unstable https://stackoverflow.com/questions/71442998/swiftui-confirmationdialog-disappearing-after-one-second
            DeleteButton {
              chatToDelete = chat
              isDeleteConfirmPresented = true
            }
          }
        }
        .onMove(perform: onMove)
      }
      .environment(\.defaultMinListRowHeight, 0)
      .scrollContentBackground(.hidden)
      .animation(.spring, value: chats.count)
    }
    .navigationBarTitle("", displayMode: .inline)
    .background(WallpaperView())
    .confirmationDialog(
      chatToDelete?.name ?? "",
      isPresented: $isDeleteConfirmPresented,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        if let c = chatToDelete {
          modelContext.delete(c)
        }
      }
    } message: {
      Text("This chat will be deleted.")
    }
  }

  private func removeChats(_ indexSet: IndexSet) {
    for index in indexSet {
      let chatToDelete = chats[index]
      modelContext.delete(chatToDelete)
    }
  }

  func onMove(from source: IndexSet, to destination: Int) {
    var updatedItems = chats
    updatedItems.move(fromOffsets: source, toOffset: destination)
    updatedItems.reIndex()
  }

  private func removeChat(_ chat: Chat) {
    modelContext.delete(chat)
  }
}

#Preview {
  LovelyPreview {
    HomePage()
  }
}
