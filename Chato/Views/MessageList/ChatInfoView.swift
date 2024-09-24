import SwiftData
import SwiftUI

struct ChatInfoView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContex
  @FocusState private var isFocused: Bool
  @State private var isClearHistoryPresented = false

  @Bindable var chat: Chat
  @State private var chatNamePlaceHolder: String = ""

  var body: some View {
    //let _ = Self.printChagesWhenDebug()
    NavigationStack {
      Form {
        Section("Chat Name") {
          TextField(chatNamePlaceHolder, text: $chat.name)
            .focused($isFocused)
        }.textCase(.none)

        Section("ChatGPT") {
          ChatOptionView(chat.option)
        }.textCase(.none)

        Section {
          Button(role: .destructive) {
            isClearHistoryPresented = true
          } label: {
            Label("Clear History", systemImage: "paintbrush")
              .foregroundColor(chat.messages.isEmpty ? .secondary : .red)
          }
          .disabled(chat.messages.isEmpty)
        }.textCase(.none)
      }
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            if chat.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              chat.name = chatNamePlaceHolder
            }
            dismiss()
          }
        }
      }
      .confirmationDialog("Clear History?",
                          isPresented: $isClearHistoryPresented,
                          titleVisibility: .visible)
      {
        Button("Clear History", role: .destructive) {
          clearMessages()
        }
      } message: {
        Text("Remove all messages of current chat.")
      }
      .onAppear {
        self.chatNamePlaceHolder = chat.name
      }
      .onDisappear {
        let newName = chat.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if newName.isEmpty {
          chat.name = chatNamePlaceHolder
        } else {
          chat.name = newName
        }
      }
      .navigationTitle("Chat Info")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: Prompt.self) { PromptEditorView($0) }
      .navigationDestination(for: String.self) { str in
        switch str {
        case "prompt list":
          PromptListView(chatOption: chat.option)
        case "new prompt":
          PromptCreateView { _ in }
        default:
          Text("navigationDestination not found for string: \(str)")
        }
      }
    }
  }

  private func clearMessages() {
    for m in chat.messages {
      modelContex.delete(m)
    }
  }
}

#Preview {
  LovelyPreview {
    ChatInfoView(chat: ChatSample.manyMessages)
  }
}
