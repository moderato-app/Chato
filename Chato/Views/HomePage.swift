import SwiftUI

struct HomePage: View {
  @Environment(\.safeAreaInsets) private var safeAreaInsets
  @Environment(\.colorScheme) private var colorScheme
  @EnvironmentObject var pref: Pref
  @State var path: NavigationPath = .init()

  @State private var settingsDetent = PresentationDetent.medium
  @State private var isSettingPresented = false
  @State private var isNewChatPresented = false
  @State var searchString = ""

  var body: some View {
//    //let _ = Self.printChagesWhenDebug()
    NavigationStack(path: $path) {
      ChatListView(searchString)
        .searchable(text: $searchString)	
        .animation(.easeInOut, value: searchString)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              isSettingPresented = true
            } label: {
              Image(systemName: "gear")
                .padding(15)
                .clipShape(Circle())
                .overlay(
                  Circle().stroke(Color.clear)
                )
            }
            .if(pref.haptics) {
              $0.sensoryFeedback(.impact(flexibility: .soft), trigger: isSettingPresented)
            }
          }

          ToolbarItem(placement: .automatic) {
            HStack(spacing: 0) {
              NavigationLink(value: "prompt list") {
                PromptIcon()
              }

              Button {
                self.isNewChatPresented = true
              } label: {
                PlusIcon()
              }
              .if(pref.haptics) {
                $0.sensoryFeedback(.impact(flexibility: .soft), trigger: isNewChatPresented)
              }
            }
          }
        }
        .lovelyNavi()
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
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

#Preview {
  LovelyPreview {
    HomePage()
  }
}
