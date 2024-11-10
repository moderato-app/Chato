import Combine
import CoreHaptics
import SwiftData
import SwiftUI

struct InputAreaView: View {
  @Environment(\.modelContext) var modelContext
  @Environment(\.openAIService) var openAIService
  @EnvironmentObject var em: EM
  @EnvironmentObject var pref: Pref

  @FocusState private var isTextEditorFocused: Bool
  @State var inputText = ""
  @State var contextLength = 0

  @State var cancellable: AnyCancellable?

  @State var subject = PassthroughSubject<String, Never>()

  let chat: Chat

  init(chat: Chat) {
    self.chat = chat
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
            let count = chat.messages.count
            if count >= 20 {
              Section("Send with context length") {
                Menu {
                  if count >= 20 { Button("20") { send(20) }}
                  if count < 50 { Button("\(count) (max)") { send(count) }}
                  if count >= 50 { Button("50") { send(50) }}
                  if count > 50 { Button("\(count) (max)") { send(count) }}
                } label: {
                  Button("More") {}
                }
              }
              ForEach([0, 1, 2, 3, 4, 6, 8, 10].reversed(), id: \.self) { i in
                Button("\(i)") { send(i) }
              }
            } else {
              if count > 10 { Button("\(count) (max)") { send(count) }}
              ForEach((0 ... 10).reversed(), id: \.self) { i in
                if i < count { Button("\(i)") { send(i) }}
                if i == count { Button("\(i) (max)") { send(i) }}
              }
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
      ask2(text: copy, contextLength: contextLength)
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
        InputAreaView(chat: ChatSample.manyMessages)
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
