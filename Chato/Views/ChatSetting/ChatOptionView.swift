import SwiftData
import SwiftUI

struct ChatOptionView: View {
  @EnvironmentObject var pref: Pref

  @Bindable private var chatOption: ChatOption
  private let pickerNavi: Bool

  init(_ chatOption: ChatOption, pickerNavi: Bool = false) {
    self.chatOption = chatOption
    self.pickerNavi = pickerNavi
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
          ForEach(chatGPTModels, id: \.value) { model in
            Text("\(model.name)").tag(model.value)
          }
        }
        .accentColor(.secondary)
        .labelsHidden()
        .modifier(SwitchablePickerStyle(isNavi: pickerNavi))
        .if(pref.haptics) {
          $0.sensoryFeedback(.selection, trigger: chatOption.model)
        }
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
        .if(pref.haptics) {
          $0.sensoryFeedback(.selection, trigger: chatOption.contextLength)
        }
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
