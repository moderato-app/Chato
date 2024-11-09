import Combine
import CoreHaptics
import SwiftData
import SwiftUI

struct InputAreaView: View {
  @Environment(NavigationContext.self) var navigationContext
  @Environment(\.modelContext) var modelContext
  @EnvironmentObject var em: EM
  @EnvironmentObject var pref: Pref

  @FocusState private var isTextEditorFocused: Bool
  @State var inputText = ""
  @State var contextLength = 0

  @State var cancellable: AnyCancellable?

  @State var subject = PassthroughSubject<String, Never>()

  let chat: Chat
  let newChatCallback: () -> Void

  init(chat: Chat, newChatCallback: @escaping () -> Void) {
    self.chat = chat
    self.newChatCallback = newChatCallback
  }

  var body: some View {
    input()
      .onAppear {
        reloadInputArea()
        setupDebounce()
      }
      .onDisappear {
        destroyDebounce()
      }
      .overlay(alignment: .topLeading) {
        if !inputText.isEmpty {
          Button(action: {
            withAnimation {
              inputText = ""
            }
            HapticsService.shared.shake(.light)
          }) {
            ClearIcon(font: .title2.bold())
          }
          .transition(.asymmetric(insertion: .scale, removal: .scale))
          .padding(.top, -24)
          .padding(.leading, 8)
        }
      }
  }

  @ViewBuilder
  func input() -> some View {
    HStack(alignment: .bottom, spacing: 0) {
      TextField("Message", text: $inputText, axis: .vertical)
        .lineLimit(1 ... (isTextEditorFocused ? 10 : 15))
        .focused($isTextEditorFocused)
        .onChange(of: inputText) { _, newText in
          debounceText(newText: newText)
        }
        .padding(.vertical, 2.5) // hight of TextFiled should be >= Send Button to prevent Button from enlarging  HStack
        .textFieldStyle(.plain)
        .onReceive(em.reUseTextEvent) { text in
          DispatchQueue.main.async {
            reuseOrCancel(text: text)
          }
        }
        .gesture(
          DragGesture()
            .onChanged { let dragAmount = $0.translation
              if inputText.count < 60, dragAmount.height < -10 {
                withAnimation {
                  isTextEditorFocused = true
                }
              }
              if inputText.count == 0, dragAmount.height < 5 {
                withAnimation {
                  isTextEditorFocused = true
                }
              }
            }
        )
        .scrollContentBackground(.hidden)

      if !inputText.isEmpty {
        Image(systemName: "arrow.up.circle.fill")
          .font(.title2.weight(.bold))
          .symbolRenderingMode(.multicolor)
          .foregroundStyle(.tint)
          .contentShape(Circle())
          .transition(.asymmetric(insertion: .scale, removal: .scale))
          .onTapGesture {
            send(chat.option.contextLength)
          }
          .contextMenu {
            Section("Send with context length") {
              Button("Infinite") { send(Int.max) }
              Button("20") { send(20) }
              Button("10") { send(10) }
              Button("8") { send(8) }
              Button("6") { send(6) }
              Button("4") { send(4) }
              Button("3") { send(3) }
              Button("2") { send(2) }
              Button("1") { send(1) }
              Button("0") { send(0) }
            }
          }
          .popoverTip(SendButtonTip.instance, arrowEdge: .top)
      }
    }
    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 4))
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(.clear)
        .strokeBorder(.secondary.opacity(0.5), lineWidth: 0.5)
    )
    .padding(EdgeInsets(top: 6, leading: 8, bottom: 12, trailing: 8))
  }

  func send(_ contextLength: Int) {
    let copy = inputText
    inputText = ""
    Task.detached {
      await delayClearInput()
    }
    isTextEditorFocused = false
    Task {
      ask(text: copy, contextLength: contextLength)
    }
  }
}

struct GradientView: View {
  var body: some View {
    TimelineView(.animation) { timeline in
      let x = Float((sin(timeline.date.timeIntervalSince1970 / 3) + 1) / 2)
      let y = Float((cos(timeline.date.timeIntervalSince1970 / 3 + 1) + 1) / 2)

      MeshGradient(width: 3, height: 3, points: [
        [0, 0], [x, 0], [1, 0],
        [0, 0.5], [x, Float(y)], [1, 0.5],
        [0, 1], [x, 1], [1, 1]
      ], colors: [
        Color(hex: "97D9E1"), Color(hex: "B8C4DD"), Color(hex: "D9AFD9"),
        Color(hex: "97D9E1"), Color(hex: "B8C4DD"), Color(hex: "D9AFD9"),
        Color(hex: "97D9E1"), Color(hex: "B8C4DD"), Color(hex: "D9AFD9")
      ])
    }
    .opacity(0.5)
  }
}

#Preview {
  LovelyPreview {
    NavigationStack {
      VStack {
        Spacer()
        InputAreaView(chat: ChatSample.manyMessages, newChatCallback: {})
      }
    }
  }
}

#Preview("ContentView") {
  LovelyPreview {
    ContentView()
  }
}

#Preview("Gradient") {
  GradientView()
    .opacity(0.2)
}
