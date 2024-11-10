import SwiftUI

struct ChatDetailView: View {
  @EnvironmentObject var pref: Pref
  @State private var isTutorialPresented = false

  let chat: Chat

  var body: some View {
    ChatDetail(chat: chat)
      .navigationTitle(chat.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .automatic)
      .softFeedback(isTutorialPresented, isTutorialPresented)
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
        }
      }
      .sheet(isPresented: $isTutorialPresented) {
        TutorialView(option: chat.option)
      }
  }
}

private struct ChatDetail: View {
  let chat: Chat

  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject var em: EM
  @State private var isInfoPresented = false
  @State private var isPromptPresented = false
  @EnvironmentObject var pref: Pref

  init(chat: Chat) {
    self.chat = chat
  }

  var body: some View {
//    let _ = Self._printChanges()
    MessageList(chat: chat)
      .softFeedback(isPromptPresented, isInfoPresented)
      .toolbar {
        ToolbarItem(placement: .automatic) {
          HStack(spacing: 0) {
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
