import SwiftData
import SwiftUI

struct MessageList: View {
  @EnvironmentObject var em: EM
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject var pref: Pref
  @State private var triggerHaptic: Bool = false

  @State private var lastMsgOnScreen = true
  @State private var position = ScrollPosition()
  @State private var messages: [Message] = []
  @State private var total = 10

  let chat: Chat

  init(chat: Chat) {
    self.chat = chat
  }

  func initMessageList() {
    messages = chat.messages
      .sorted(by: { a, b in a.createdAt > b.createdAt })
      .prefix(total)
      .reversed()
  }

  func onMsgCountChange() {
    // Skip animation if there are too many history messages to avoid clutter
    let ani = total == 10
    total = 10
    Task.detached {
      try await Task.sleep(for: .seconds(0.05))
      Task { @MainActor in
        withAnimation(ani ? .default : .none) {
          initMessageList()
        }
      }
      try await Task.sleep(for: .seconds(1))
      Task { @MainActor in
        withAnimation(ani ? .default : .none) {
          initMessageList()
        }
      }
    }
  }

  var body: some View {
    ScrollView {
      ForEach(messages, id: \.self) { msg in
        NormalMsgView(msg: msg, deleteCallback: onMsgCountChange)
          .id(msg.id)
          .if(pref.magicScrolling) { c in
            c.visualEffect { content, proxy in
              let frame = proxy.frame(in: .scrollView(axis: .vertical))
              let distance = min(0, frame.height > UIScreen.main.bounds.height / 4 ? 0 : frame.minY)
              var scale = (1 + distance / 700)
              if scale < 0 {
                scale = 0
              }
              let y = scale < 0 ? 0 : -distance / 1.25
              return content
                .scaleEffect(scale)
                .offset(y: y)
                .blur(radius: -distance / 50)
            }
          }
      }
      .padding(10)
      .scrollTargetLayout()
    }
    .defaultScrollAnchor(.bottom)
    .scrollPosition($position, anchor: .bottom)
    .onScrollTargetVisibilityChange(idType: PersistentIdentifier.self, threshold: 0.001) { onScreenIds in
      lastMsgOnScreen = onScreenIds.contains(where: { it in it == messages.last?.persistentModelID })
    }
    .scrollDismissesKeyboard(.interactively)
    .removeFocusOnTap()
    .safeAreaInset(edge: .top, spacing: 0) {
      VisualEffectView(isDark: colorScheme == .dark)
        .ignoresSafeArea(edges: .top)
        .frame(height: 0)
    }
    .onReceive(em.messageEvent) { event in
      if event == .new {
        withAnimation {
          position.scrollTo(edge: .bottom)
        }
      }
    }
    .safeAreaInset(edge: .bottom, spacing: 0) {
      InputAreaView(chat: chat, newChatCallback: onMsgCountChange)
        .background(VisualEffectView(isDark: colorScheme == .dark)
          .ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .topTrailing) {
          HStack {
            if !lastMsgOnScreen {
              Button {
                withAnimation {
                  position.scrollTo(edge: .bottom)
                }
                Task.detached {
                  try await Task.sleep(for: .seconds(0.2))
                  Task { @MainActor in
                    triggerHaptic.toggle()
                  }
                }
              } label: {
                ToBottomIcon()
              }
              .transition(.scale.combined(with: .opacity))
            }
          }
          .animation(.default, value: lastMsgOnScreen)
          .offset(y: -60)
          .offset(x: -15)
        }
    }
    .if(pref.haptics) {
      $0.sensoryFeedback(.impact(flexibility: .soft), trigger: triggerHaptic)
    }
    .onAppear {
      initMessageList()
      position.scrollTo(edge: .bottom)
    }
    .refreshable {
      if messages.count == total {
        total += 20
        withAnimation {
          initMessageList()
        }
      } else {
        HapticsService.shared.shake(.error)
      }
    }
  }
}

#Preview {
  LovelyPreview {
    MessageList(chat: ChatSample.manyMessages)
  }
}
