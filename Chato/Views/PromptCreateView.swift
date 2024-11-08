import SwiftUI

struct PromptCreateView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss

  @State var name: String
  @State var messages: [PromptMessage]
  @FocusState private var focusedItemID: String?
  @EnvironmentObject var pref: Pref

  var onCreate: (Prompt) -> Void

  init(onCreate: @escaping ((Prompt) -> Void) = { _ in }) {
    _name = State(initialValue: "")
    _messages = State(initialValue: [PromptMessage(content: "", order: 0)])
    self.onCreate = onCreate
  }

  var body: some View {
    List {
      Section("Prompt Name") {
        TextField("", text: $name)
          .focused($focusedItemID, equals: "Prompt name")
      }
      .textCase(.none)

      ForEach(messages) { message in
        @Bindable var msg = message
        HStack {
          if msg.role == .user {
            Spacer.widthPercent(0.1)
          }
          if msg.role == .system {
            Spacer.widthPercent(0.05)
          }

          ZStack(alignment: .topLeading) {
            TextField("Message", text: $msg.content, axis: .vertical)
              .lineLimit(1 ... 10)
              .padding(10)
              .background(roleToColor(message.role).opacity(colorScheme == .light ? 0.1 : 0.6))
              .cornerRadius(10)
              .focused($focusedItemID, equals: msg.uuid)

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
              .if(pref.haptics) {
                $0.sensoryFeedback(.selection, trigger: msg.role)
              }
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
      }
      .onMove(perform: onMove)
      .onDelete(perform: remove)

      Button {
        let m = PromptMessage(content: "", role: .system, order: 0)
        messages.append(m)
        messages.reIndex()
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
    .animation(.default, value: messages)
    .animation(.default, value: focusedItemID)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("OK") {
          let order = modelContext.nextPromptOrder()
          let promptToCreate = Prompt(name: name, messages: messages, order: order)
          modelContext.insert(promptToCreate)
          onCreate(promptToCreate)
          dismiss()
        }
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("New Prompt")
  }

  func onMove(from source: IndexSet, to destination: Int) {
    var updatedItems = messages
    updatedItems.move(fromOffsets: source, toOffset: destination)
    updatedItems.reIndex()
    messages = updatedItems
  }

  private func remove(_ indexSet: IndexSet) {
    for index in indexSet {
      messages.remove(at: index)
    }
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

#Preview {
  PromptCreateView()
}
