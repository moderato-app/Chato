import SwiftData
import SwiftUI

struct PromptListView: View {
  @State var searchString = ""
  var chatOption: ChatOption?
  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    ListPrompt(chatOption: chatOption, searchString: searchString)
      .searchable(text: $searchString)
//      .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
      .animation(.easeInOut, value: searchString)
  }
}

private struct ListPrompt: View {
  private static let sortOrder = [SortDescriptor(\Prompt.order, order: .reverse)]

  var chatOption: ChatOption?
  @Query(sort: \Prompt.order, order: .reverse) private var prompts: [Prompt]
  @State var isCreatePromptPresented = false

  init(chatOption: ChatOption? = nil, searchString: String) {
    self.chatOption = chatOption
    _prompts = Query(filter: #Predicate {
      searchString.isMeaningless || $0.name.localizedStandardContains(searchString.meaningfulString)
    }, sort: Self.sortOrder)
  }

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    ListPromptNoQuery(chatOption: chatOption, prompts: prompts)
  }
}

private struct ListPromptNoQuery: View {
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var em: EM

  @State var promptToDelete: Prompt?
  @State var isDeleteConfirmPresented: Bool = false
  @State var isCreatePromptPresented = false

  var chatOption: ChatOption?
  private var myPrompts: [Prompt]
  private var presets: [Prompt]

  init(chatOption: ChatOption? = nil, prompts: [Prompt]) {
    self.chatOption = chatOption
    self.myPrompts = prompts.filter { !$0.preset }
    self.presets = prompts.filter { $0.preset }
  }

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    List {
      if !myPrompts.isEmpty {
        Section(myPrompts.count > 5 ? "My Prompts (\(myPrompts.count))" : "My Prompts") {
          ForEach(myPrompts, id: \.persistentModelID) { prompt in
            NavigationLink(value: prompt) {
              PromptRowView(prompt: prompt, showCircle: chatOption != nil, id: chatOption?.prompt?.persistentModelID)
            }
            .modifier(
              SwitchableListRowInsets(chatOption != nil, EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 10))
            )
            .lovelyRow()
            .swipeActions {
              DeleteButton {
                promptToDelete = prompt
                isDeleteConfirmPresented = true
              }
              DupButton {
                let p2 = prompt.copy(order: myPrompts.count)
                modelContext.insert(p2)
              }
            }
          }
          .onMove(perform: movePrompts)
        }
        .textCase(.none)
      }

      if !presets.isEmpty {
        Section(presets.count > 5 ? "Presets (\(presets.count))" : "") {
          ForEach(presets, id: \.persistentModelID) { prompt in
            NavigationLink(value: prompt) {
              PromptRowView(prompt: prompt, showCircle: chatOption != nil, id: chatOption?.prompt?.persistentModelID)
            }
            .modifier(
              SwitchableListRowInsets(chatOption != nil, EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 10))
            )
            .lovelyRow()
            .swipeActions(allowsFullSwipe: false) {
              DeleteButton {
                promptToDelete = prompt
                isDeleteConfirmPresented = true
              }
              DupButton {
                let p2 = prompt.copy(order: myPrompts.count)
                modelContext.insert(p2)
              }
            }
          }
          .onMove(perform: movePresets)
        }
        .textCase(.none)
      }
    }
    .modifier(JustScrollView(chatOption?.prompt?.persistentModelID))
    .scrollContentBackground(.hidden)
    .background(WallpaperView())
    .animation(.spring, value: myPrompts.count)
    .animation(.spring, value: presets.count)
    .toolbar {
      Button {
        isCreatePromptPresented.toggle()
      }
      label: {
        PlusIcon()
      }
    }
    .sheet(isPresented: $isCreatePromptPresented) {
      NavigationStack {
        PromptCreateView { _ in }
      }
    }
    .confirmationDialog(
      promptToDelete?.name ?? "",
      isPresented: $isDeleteConfirmPresented,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        if let prompt = promptToDelete {
          modelContext.delete(prompt)
          if let co = chatOption, co.prompt == prompt {
            co.prompt = nil
          }
        }
      }
    } message: {
      Text("This prompt will be deleted.")
    }
    .navigationBarTitle("Prompts", displayMode: .inline)
    .onReceive(em.chatOptionPromptChangeEvent) { id in
      if let co = chatOption {
        withAnimation(.bouncy(duration: 0.2)) {
          if let id = id {
            co.prompt = modelContext.findPromptById(promptId: id)
          } else {
            co.prompt = nil
          }
        }
      }
    }
  }

  private func remove(_ indexSet: IndexSet) {
    for index in indexSet {
      let toDelete = myPrompts[index]
      modelContext.delete(toDelete)
    }
  }

  func movePrompts(from source: IndexSet, to destination: Int) {
    var updatedItems = myPrompts
    updatedItems.move(fromOffsets: source, toOffset: destination)
    updatedItems.reIndex()
  }

  func movePresets(from source: IndexSet, to destination: Int) {
    var updatedItems = presets
    updatedItems.move(fromOffsets: source, toOffset: destination)
    updatedItems.reIndex()
  }
}

#Preview("PromptListView") {
  ModelContainerPreview(ModelContainer.preview) {
    NavigationStack {
      PromptListView()
    }
  }
}
