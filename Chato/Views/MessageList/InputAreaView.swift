import Combine
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
  let newChatCallback: ()->Void
  
  init(chat: Chat, newChatCallback: @escaping ()->Void) {
    self.chat = chat
    self.newChatCallback = newChatCallback
  }

  var body: some View {
    VStack {
      TextField("", text: $inputText, axis: .vertical)
        .textInputAutocapitalization(.never)
        .lineLimit(1 ... (isTextEditorFocused ? 10 : 15))
        .padding(10)
        .background(.clear)
        .focused($isTextEditorFocused)
        .onChange(of: inputText) { _, newText in
          debounceText(newText: newText)
        }
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
    }
    .background(
      GradientView()
        .onTapGesture {
          isTextEditorFocused = true
        }
    )
    .cornerRadius(15)
    .overlay(alignment: .topLeading) {
      if !inputText.isEmpty {
        Button(action: {
          withAnimation {
            inputText = ""
          }
          HapticsService.shared.shake(.light)
        }) {
          ClearIcon(font: .title)
        }
        .keyboardShortcut("k", modifiers: .command)
        .transition(.asymmetric(insertion: .scale, removal: .scale))
        .padding(.top, -34)
      }
    }
    .overlay(alignment: .topTrailing) {
      if !inputText.isEmpty {
        HStack {
          Button {
            let copy = inputText
            inputText = ""
            Task.detached {
              await delayClearInput()
            }
            isTextEditorFocused = false
            Task {
              ask(text: copy, useContext: false)
            }
          } label: {
            SendIconLight(.title)
          }
          .disabled(inputText.isEmpty)
          .keyboardShortcut(.return, modifiers: [.command, .shift])
          .transition(.asymmetric(insertion: .scale, removal: .scale))

          Button {
            let copy = inputText
            inputText = ""
            Task.detached {
              await delayClearInput()
            }
            isTextEditorFocused = false
            Task {
              ask(text: copy, useContext: true)
            }
          } label: {
            SendIcon(.title)
          }
          .disabled(inputText.isEmpty)
          .keyboardShortcut(.return, modifiers: .command)
          .transition(.asymmetric(insertion: .scale, removal: .scale))
          .if(contextLength == 0) {
            $0.disabled(true)
              .opacity(0)
              .allowsHitTesting(false)
          }
        }
        .padding(.top, -34)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .padding(.horizontal, 16)
    .onAppear {
      reloadInputArea()
      setupDebounce()
    }
    .onDisappear {
      destroyDebounce()
    }
    .onReceive(em.chatOptionContextLengthChangeEvent) { _ in
      reloadInputArea()
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
