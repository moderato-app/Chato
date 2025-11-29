import SwiftData
import SwiftUI

struct ChatOptionView: View {
  @EnvironmentObject var pref: Pref
  @Environment(\.modelContext) private var modelContext

  @Bindable private var chatOption: ChatOption
  private let pickerNavi: Bool

  @Query private var allModels: [ModelEntity]
  @State private var showingModelSelection = false

  init(_ chatOption: ChatOption, pickerNavi: Bool = false) {
    self.chatOption = chatOption
    self.pickerNavi = pickerNavi
  }

  private var selectedModel: ModelEntity? {
    allModels.first { $0.id == chatOption.model?.id }
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

      Button {
        showingModelSelection = true
      } label: {
        HStack {
          Label("Model", systemImage: "book")
          Spacer()
          if let model = selectedModel {
            VStack(alignment: .trailing, spacing: 2) {
              Text(model.resolvedName)
                .foregroundColor(.secondary)
              Text(model.provider.displayName)
                .font(.caption2)
                .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
          } else {
            Text(chatOption.model?.resolvedName ?? "")
              .foregroundColor(.secondary)
          }
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundColor(Color(uiColor: .tertiaryLabel))
        }
      }
      .buttonStyle(.plain)

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
    .sheet(isPresented: $showingModelSelection) {
      ModelSelectionView(chatOption: chatOption)
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
