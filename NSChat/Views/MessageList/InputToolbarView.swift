import SwiftData
import SwiftUI

struct InputToolbarView: View {
  @Query(filter: #Predicate<Provider> { $0.enabled }) private var providers: [Provider]
  @Query private var allModels: [ModelEntity]
  
  @Bindable var chatOption: ChatOption
  @State private var isWebSearchEnabled = false
  
  private var favoritedModels: [ModelEntity] {
    let filtered = allModels.filter { $0.favorited }
    return ModelEntity.smartSort(filtered)
  }
  
  private var groupedProviders: [(provider: Provider, models: [ModelEntity])] {
    allModels.groupedByProvider()
      .filter { $0.provider.enabled }
  }
  
  private var selectedModel: ModelEntity? {
    chatOption.model
  }
  
  var body: some View {
    HStack(spacing: 8) {
      // Model Picker
      Menu {
        // Favorite models section
        if !favoritedModels.isEmpty {
          ForEach(favoritedModels) { model in
            Button {
              chatOption.model = model
            } label: {
              HStack {
                Text(model.resolvedName)
                Spacer()
                if model.id == selectedModel?.id {
                  Image(systemName: "checkmark")
                }
              }
            }
          }
          Divider()
        }
        
        // Provider sections
        ForEach(groupedProviders, id: \.provider.id) { group in
          Menu(group.provider.displayName) {
            ForEach(group.models) { model in
              Button {
                chatOption.model = model
              } label: {
                Label {
                  Text(model.resolvedName)
                } icon: {
                  if model.id == selectedModel?.id {
                    Image(systemName: "checkmark")
                  }
                }
              }
            }
          }
        }
        
        Divider()
        
        // More (Settings)
        Button {
          // TODO: Navigate to settings
        } label: {
          Label("More", systemImage: "ellipsis")
        }
      } label: {
        HStack(spacing: 4) {
          if let model = selectedModel {
            Text(model.resolvedName)
              .lineLimit(1)
          } else {
            Text("Select Model")
              .foregroundStyle(.secondary)
          }
          Image(systemName: "chevron.down")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .font(.caption)
      }
      .controlSize(.small)
//      .menuStyle(.automatic)
//      .tint(.primary)

      // History Messages Size Picker
      Picker("History", selection: $chatOption.contextLength) {
        ForEach(contextLengthChoices.reversed(), id: \.self) { choice in
          Text(choice.lengthString)
            .tag(choice.length)
        }
      }
      .controlSize(.small)
      .if(chatOption.contextLength == 0) {
        $0.tint(.primary)
      }
//      .pickerStyle(.automatic)
//      .tint(.primary)

      // Web Search Switch
      Button {
        isWebSearchEnabled.toggle()
      } label: {
        Image(systemName: "globe")
          .foregroundColor(isWebSearchEnabled ? Color.accentColor : .secondary)
      }
      .animation(.none, value: isWebSearchEnabled)
      .buttonStyle(.plain)
      .controlSize(.small)

      Spacer()
    }
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    VStack {
      Spacer()
      InputToolbarView(chatOption: ChatSample.greetings.option)
    }
  }
}
