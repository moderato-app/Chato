import SwiftData
import SwiftUI

struct ChatOptionView: View {
  @EnvironmentObject var pref: Pref
  @Environment(\.modelContext) private var modelContext

  @Bindable private var chatOption: ChatOption
  private let pickerNavi: Bool

  @Query(sort: \ModelModel.modelId, order: .forward) var models: [ModelModel]

  init(_ chatOption: ChatOption, pickerNavi: Bool = false) {
    self.chatOption = chatOption
    self.pickerNavi = pickerNavi
    _models = Query(sort: \ModelModel.modelId, order: .forward)
  }

  var body: some View {
    // let _ = Self.printChagesWhenDebug()
    Group {
      NavigationLink(value: "prompt list") {
        HStack {
          Label("Prompt", systemImage: "warninglight")
          if let name = chatOption.prompt?.name {
            Spacer()
            Text(name)
              .foregroundStyle(.secondary)
          }
        }
      }

      HStack {
        Label("Model", systemImage: "book")
        Spacer()
        Picker("", selection: $chatOption.model) {
          ForEach(models, id: \.modelId) { model in
            Text("\(model.resolvedName)").tag(model.modelId)
          }
        }
        .accentColor(.secondary)
        .labelsHidden()
        .modifier(SwitchablePickerStyle(isNavi: pickerNavi))
        .selectionFeedback(chatOption.model)
      }
      VStack(alignment: .leading) {
        Label("Context Length", systemImage: "square.3.layers.3d.down.left")
        Picker("Context Length", selection: $chatOption.contextLength) {
          ForEach(contextLengthChoices, id: \.self) { c in
            Text("\(c.lengthString)")
              .tag(c.length)
          }
        }
        .pickerStyle(.segmented)
        .selectionFeedback(chatOption.contextLength)
      }
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    Form {
      ChatOptionView(ChatSample.greetings.option)
    }
  }
}
