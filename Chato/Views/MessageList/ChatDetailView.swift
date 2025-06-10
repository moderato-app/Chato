import SwiftUI

struct ChatDetailView: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isTutorialPresented = false
  @State private var isSettingPresented = false

  let chat: Chat

  var body: some View {
//    let _ = Self.printChagesWhenDebug()
    ChatDetail(chat: chat)
      .navigationTitle(chat.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .automatic)
      .softFeedback(isTutorialPresented, isSettingPresented)
      .toolbar {
        ToolbarTitleMenu {
          Section {
            Button {
              isTutorialPresented.toggle()
            } label: {
              HStack {
                Text("Help")
                Image(systemName: "accessibility")
              }
            }
          }

          Section {
            Button {
              isSettingPresented.toggle()
            } label: {
              HStack {
                Text("Settings")
                Image(systemName: "gear")
              }
            }
          }
        }
      }
      .sheet(isPresented: $isTutorialPresented) {
        TutorialView(option: chat.option)
      }
      .sheet(isPresented: $isSettingPresented) {
        SettingView()
          .preferredColorScheme(colorScheme)
          .presentationDetents([.large])
      }
  }
}

private struct ChatDetail: View {
  let chat: Chat

  @EnvironmentObject var em: EM
  @State private var isInfoPresented = false
  @State private var isPromptPresented = false

  init(chat: Chat) {
    self.chat = chat
  }

  var body: some View {
//    let _ = Self._printChanges()
    MessageList(chat: chat)
      .softFeedback(isPromptPresented, isInfoPresented)
      .toolbar {
        ToolbarItem(placement: .automatic) {
          Button {
            self.isPromptPresented.toggle()
          } label: {
            PromptIcon(chatOption: chat.option)
              .tint(.secondary)
          }
          .sheet(isPresented: $isPromptPresented) {
            NavigationStack {
              if let p = chat.option.prompt {
                PromptEditorView(p)
                  .toolbar { Button("OK") { isPromptPresented.toggle() } }
              } else {
                PromptCreateView { p in
                  chat.option.prompt = p
                }
              }
            }
            .presentationDetents([.large])
          }
        }
        ToolbarSpacer(.fixed)
        ToolbarItem(placement: .automatic) {
          Button {
            self.isInfoPresented.toggle()
          } label: {
            ContextLengthCircle(chat.option.contextLength, chat.isBestModel)
              .padding(2)
              .clipShape(Circle())
              .overlay(
                Circle().stroke(Color.clear)
              )
          }
          .sheet(isPresented: $isInfoPresented) {
            ChatInfoView(chat: chat)
              .presentationDetents([.large])
          }
        }
      }
      .onReceive(em.messageEvent) { event in
        switch event {
        case .new:
          HapticsService.shared.shake(.light)
        case .eof:
          Task {
            await sleepFor(0.2)
            HapticsService.shared.shake(.success)
          }
        case .err:
          Task {
            await sleepFor(0.2)
            HapticsService.shared.shake(.error)
          }
        case .countChanged:
          break
        }
      }
  }
}

#Preview {
  LovelyPreview {
    NavigationStack {
      ChatDetailView(chat: ChatSample.manyMessages)
    }
  }
}
