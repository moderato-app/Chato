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

  @State var editMode: EditMode = .inactive

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
    list()
  }

  @State var selectedChatIDs = Set<PersistentIdentifier>()

  @ViewBuilder
  func list() -> some View {
    List(selection: $selectedChatIDs) {
      ForEach(chats, id: \.persistentModelID) { chat in
        ChatRowView(chat: chat)
          .listRowInsets(SwiftUICore.EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
          .background(
            NavigationLink(value: chat){}
              .opacity(0)
          )
          .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Avoid using the `chat` variable in the confirm dialog. Swipe actions seem to re-calculate
            // the list, which might delete the wrong chat.
            // Don't use role = .destructive, or confirmation dialog animation becomes unstable https://stackoverflow.com/questions/71442998/swiftui-confirmationdialog-disappearing-after-one-second
            DeleteButton {
              chatToDelete = chat
              isDeleteConfirmPresented = true
            }
          }
        //        .swipeActions(edge: .leading, allowsFullSwipe: true) {
        //          Button("", systemImage: "message.badge.fill") {
        //            store.send(.chats(.element(id: chat.id, action: .onRead(!chat.read))))
        //          }.tint(.blue)
        //        }
      }
      .onMove(perform: onMove)
    }
    .listStyle(.plain)
    .navigationTitle("Chats")
    .transNavi()
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
    .toolbar {
      toolbarItems()
    }

    // ensure the .environment() modifier is placed after the .toolbar() modifier
    .environment(\.editMode, $editMode)
    .onAppear {
      selectedChatIDs = .init()
    }
  }

  @ToolbarContentBuilder
  func toolbarItems() -> some ToolbarContent {
    ToolbarItem {
      if editMode == .active {
        #if os(iOS)
        Button("Done") {
          withAnimation {
            editMode = .inactive
            selectedChatIDs = .init()
          }
        }.fontWeight(.semibold)
        #endif
      } else {
        Menu("", systemImage: "ellipsis.circle") {
          Button("Prompts", systemImage: "p.square") {}
//          Button("Statistics", systemImage: "chart.line.uptrend.xyaxis") {}
          if !chats.isEmpty {
            #if os(iOS)
            Button("Select Chats", systemImage: "checkmark.circle") {
              withAnimation {
                editMode = .active
              }
            }
            #endif
          }
          Section {
            Button("Settings", systemImage: "gear") {}
          }
        }
      }
    }
    #if os(iOS)
    let p = ToolbarItemPlacement.navigationBarTrailing
    #elseif os(macOS)
    let p = ToolbarItemPlacement.automatic
    #endif
    ToolbarItem(placement: p) {
      if editMode != .active {
        Button(action: {}) {
          Image(systemName: "square.and.pencil")
        }
        .contextMenu {
          Button("New Chat", systemImage: "square.and.pencil") {}
          Button("New Prompt", systemImage: "p.square") {}
          Button("New Tag", systemImage: "tag") {}

          Section("Experimental") {
            Button("Generate Image", systemImage: "photo") {}
            ControlGroup {
              Button("Camera", systemImage: "camera") {}
              Button("Photo Library", systemImage: "photo") {}
            }
          }
        }
      }
    }
    #if os(iOS)
    ToolbarItem(placement: .bottomBar) {
      if editMode == .active {
        HStack {
          Spacer()
          Button("Delete") {
            removeChats(selectedChatIDs)
          }
          .disabled(selectedChatIDs.isEmpty)
        }
      }
    }
    #endif
  }

  private func removeChats(_ indexSet: IndexSet) {
    for index in indexSet {
      let chatToDelete = chats[index]
      modelContext.delete(chatToDelete)
    }
  }

  private func removeChats(_ selectedChatIDs: Set<PersistentIdentifier>) {
    for id in selectedChatIDs {
      if let chatToDelete = chats.filter({ $0.persistentModelID == id }).first {
        modelContext.delete(chatToDelete)
      }
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
