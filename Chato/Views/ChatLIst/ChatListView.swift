import SwiftData
import SwiftUI

struct ChatListView: View {
  private static let sortOrder = [SortDescriptor(\Chat.order, order: .reverse)]

  @Environment(\.modelContext) private var modelContext
  @Environment(\.colorScheme) private var colorScheme
  @EnvironmentObject var pref: Pref
  @Query(sort: \Chat.createdAt) private var chats: [Chat]

  @State private var settingsDetent = PresentationDetent.medium
  @State private var isSettingPresented = false
  @State private var isNewChatPresented = false

  @State var isDeleteConfirmPresented: Bool = false
  @State var isMultiDeleteConfirmPresented: Bool = false
  @State var chatToDelete: Chat?

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
      .sheet(isPresented: $isSettingPresented) {
        SettingView()
          .preferredColorScheme(colorScheme)
          .presentationDetents([.large])
      }
      .sheet(isPresented: $isNewChatPresented) {
        NewChatView()
          .presentationDetents(
            [.medium, .large],
            selection: $settingsDetent
          )
      }
      .if(pref.haptics) {
        $0.sensoryFeedback(.impact(flexibility: .soft), trigger: editMode)
          .sensoryFeedback(.impact(flexibility: .soft), trigger: isSettingPresented)
          .sensoryFeedback(.impact(flexibility: .soft), trigger: isNewChatPresented)
          .sensoryFeedback(.impact(flexibility: .soft), trigger: isMultiDeleteConfirmPresented)
      }
  }

  @State var selectedChatIDs = Set<PersistentIdentifier>()

  @ViewBuilder
  func list() -> some View {
    List(selection: $selectedChatIDs) {
      ForEach(chats, id: \.persistentModelID) { chat in
        ChatRowView(chat: chat)
          .listRowInsets(SwiftUICore.EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 10))
          .background(
            NavigationLink(value: chat) {}
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
    .animation(.default, value: chats.count)
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
    .confirmationDialog(
      "\(selectedChatIDs.count) chat(s) in total",
      isPresented: $isMultiDeleteConfirmPresented,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        removeChats(selectedChatIDs)
        selectedChatIDs = .init()
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
        Button("Done") {
          withAnimation {
            editMode = .inactive
            selectedChatIDs = .init()
          }
        }.fontWeight(.semibold)
      } else {
        Menu("", systemImage: "ellipsis.circle") {
          NavigationLink(value: "prompt list") {
            Label("Prompts", systemImage: "p.square")
          }
          if !chats.isEmpty {
            Button("Select Chats", systemImage: "checkmark.circle") {
              withAnimation {
                editMode = .active
              }
            }
          }
          Section {
            Button("Settings", systemImage: "gear") {
              isSettingPresented.toggle()
            }
          }
        }
      }
    }
    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
      if editMode != .active {
        Button {
          self.isNewChatPresented.toggle()
        } label: {
          PlusIcon()
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
    ToolbarItem(placement: .bottomBar) {
      if editMode == .active {
        HStack {
          Spacer()
          Button("Delete") {
            isMultiDeleteConfirmPresented.toggle()
          }
          .disabled(selectedChatIDs.isEmpty)
        }
      }
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
