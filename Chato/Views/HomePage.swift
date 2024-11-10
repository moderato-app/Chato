import SwiftUI

struct HomePage: View {
  @State var searchString = ""

  var body: some View {
//    //let _ = Self.printChagesWhenDebug()
    NavigationStack {
      ChatListView(searchString)
        .searchable(text: $searchString)
        .animation(.easeInOut, value: searchString)
        .navigationDestination(for: Chat.self) { chat in
          ChatDetailView(chat: chat)
        }
        .navigationDestination(for: Prompt.self) { PromptEditorView($0) }
        .navigationDestination(for: String.self) { str in
          switch str {
          case "prompt list":
            PromptListView()
          case "new prompt":
            PromptCreateView { _ in }
          default:
            Text("navigationDestination not found for string: \(str)")
          }
        }
        .navigationTitle("Chats")
        .transNavi()
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

#Preview {
  LovelyPreview {
    HomePage()
  }
}
