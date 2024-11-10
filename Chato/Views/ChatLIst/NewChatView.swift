import SwiftData
import SwiftUI

struct NewChatView: View {
  @Environment(\.modelContext) var modelContext
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var pref: Pref
  @State var chatName = ""
  @State var chatOption: ChatOption = .init()
  @FocusState private var isFocused: Bool
  @State private var triggerHaptic: Bool = false
  @State private var detent = PresentationDetent.medium

  private var chatNamePlaceHolder: String {
    if let prompt = chatOption.prompt {
      prompt.name
    } else {
      "New Chat at " + Date.now.formatted(date: .omitted, time: .shortened)
    }
  }

  var body: some View {
    // let _ = Self.printChagesWhenDebug()
    NavigationStack {
      Form {
        Section("Name") {
          TextField(chatNamePlaceHolder, text: $chatName)
            .focused($isFocused)
        }.textCase(.none)

        Section("ChatGPT") {
          ChatOptionView(chatOption)
        }.textCase(.none)
      }
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            if chatName.isMeaningless {
              chatName = chatNamePlaceHolder
            }

            pref.lastUsedModel = chatOption.model
            pref.lastUsedContextLength = chatOption.contextLength

            dismiss()
            triggerHaptic.toggle()
            // chat list animation conflicts with dismiss()
            // do it a little bit later
            Task.detached {
              try await Task.sleep(for: .seconds(0.1))
              Task { @MainActor in
                modelContext.insert(Chat(name: chatName, option: chatOption))
              }
            }
          }
          .if(pref.haptics) {
            $0.sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: triggerHaptic)
          }
        }
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      .navigationTitle("New Chat")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: Prompt.self) { PromptEditorView($0) }
      .navigationDestination(for: String.self) { str in
        switch str {
        case "prompt list":
          PromptListView(chatOption: chatOption)
        case "new prompt":
          PromptCreateView { _ in }
        default:
          Text("navigationDestination not found for string: \(str)")
        }
      }
      .onAppear {
        load()
      }
    }
  }

  func load() {
    if let model = pref.lastUsedModel {
      chatOption.model = model
    }
    if let cl = pref.lastUsedContextLength {
      chatOption.contextLength = cl
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    NavigationStack {
      NewChatView()
    }
  }
}
