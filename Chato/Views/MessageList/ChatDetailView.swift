import Haptico
import SwiftData
import SwiftUI
import Throttler

struct ChatDetailView: View {
  let chat: Chat
  @State private var isTutorialPresented = false
  @EnvironmentObject var pref: Pref

  var body: some View {
    ChatDetail(chat: chat)
      .navigationTitle(chat.name)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .automatic)
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
      .if(pref.haptics) {
        $0.sensoryFeedback(.impact(flexibility: .soft), trigger: isTutorialPresented)
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
            .if(pref.haptics) {
              $0.sensoryFeedback(.impact(flexibility: .soft), trigger: isPromptPresented)
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
            .if(pref.haptics) {
              $0.sensoryFeedback(.impact(flexibility: .soft), trigger: isInfoPresented)
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
