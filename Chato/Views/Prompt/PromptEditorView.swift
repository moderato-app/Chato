import SwiftData
import SwiftUI

struct PromptEditorView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.colorScheme) var colorScheme

  @Bindable var prompt: Prompt
  @FocusState private var focusedItemID: String?

  init(_ p: Prompt) {
    self.prompt = p
  }

  var body: some View {
    List {
      Section("Prompt Name") {
        TextField("", text: $prompt.name)
          .focused($focusedItemID, equals: "Prompt name")
      }
      .textCase(.none)

      ForEach(prompt.messages.sorted()) { message in
        @Bindable var msg = message
        HStack {
          if msg.role == .user {
            Spacer.widthPercent(0.1)
          }
          if msg.role == .system {
            Spacer.widthPercent(0.05)
          }

          TextField("Message", text: $msg.content, axis: .vertical)
            .lineLimit(1 ... 10)
            .padding(10)
            .background(roleToColor(message.role).opacity(colorScheme == .light ? 0.1 : 0.6))
            .cornerRadius(10)
            .focused($focusedItemID, equals: msg.uuid)
            .overlay(alignment: .topLeading) {
              if focusedItemID == msg.uuid {
                Picker("", selection: $msg.role) {
                  ForEach(Message.MessageRole.allCases, id: \.self) { r in
                    Text("\(r.rawValue)").foregroundStyle(.blue)
                  }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.top, -33)
                .transition(.asymmetric(insertion: .scale, removal: .scale))
                .animation(.default, value: focusedItemID)
                .selectionFeedback(msg.role)
              }
            }
            .animation(.default, value: message.role)
          if msg.role == .assistant {
            Spacer.widthPercent(0.1)
          }
          if msg.role == .system {
            Spacer.widthPercent(0.05)
          }
        }
        .padding(.top, 33)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .buttonStyle(.plain)
        .swipeActions {
          DeleteButton {
            prompt.messages.removeAll(where: { $0.persistentModelID == msg.persistentModelID })
            modelContext.delete(msg)
          }
        }
      }
      .onMove(perform: onMove)
      .animation(.bouncy, value: prompt.messages.count)

      Button {
        let count = modelContext.promptCount()
        let m = PromptMessage(content: "", role: .system, order: count)
        var sorted = prompt.messages.sorted()
        sorted.append(m)
        sorted.reIndex()
        prompt.messages = sorted
        focusedItemID = nil
      } label: {
        Image(systemName: "plus.circle.fill")
          .foregroundColor(.green)
          .font(.title)
      }
      .buttonStyle(.plain)
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets())
      .listRowSeparator(.hidden)
      .frame(maxWidth: .infinity)
      .padding(.top, 20)
    }
    .listRowBackground(Color.clear)
    .scrollDismissesKeyboard(.immediately)
    .animation(.default, value: prompt.messages)
    .animation(.default, value: focusedItemID)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Prompt")
  }

  func onMove(from source: IndexSet, to destination: Int) {
    var updatedItems = prompt.messages.sorted()
    updatedItems.move(fromOffsets: source, toOffset: destination)
    updatedItems.reIndex()
    prompt.messages = updatedItems
  }

  func roleToColor(_ role: Message.MessageRole) -> Color {
    switch role {
    case .system:
      Color.purple
    case .assistant:
      Color.gray
    case .user:
      Color.blue
    }
  }
}

#Preview() {
  LovelyPreview {
    PromptEditorView(PromptSample.userDefault)
  }
}
