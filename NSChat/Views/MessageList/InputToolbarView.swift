import SwiftData
import SwiftUI
import SystemNotification

struct InputToolbarView: View {
  @Query(filter: #Predicate<Provider> { $0.enabled }) private var providers: [Provider]
  @Query private var allModels: [ModelEntity]

  @Bindable var chatOption: ChatOption
  @Binding var inputText: String
  @State private var isWebSearchEnabled = false
  @EnvironmentObject private var notificationContext: SystemNotificationContext

  private var favoritedModels: [ModelEntity] {
    let filtered = allModels.filter { $0.favorited }
    return ModelEntity.smartSort(filtered)
  }

  private var groupedProviders: [(provider: Provider, models: [ModelEntity])] {
    let grouped = allModels.groupedByProvider()
      .filter { $0.provider.enabled }
    // Ensure stable sorting by displayName
    return grouped.sorted { $0.provider.displayName < $1.provider.displayName }
  }

  private var selectedModel: ModelEntity? {
    chatOption.model
  }

  var body: some View {
    HStack(spacing: 8) {
      // Clear Button
      if !inputText.isEmpty {
        clearButtonContent()
          .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
      }

      // Model Picker
      modelPickerContent()

      // History and Web Search Controls
      historyPickerContent()
      webSearchContent()

      Spacer()
    }
    .animation(.default, value: inputText.isEmpty)
    .animation(.default, value: chatOption.model)
  }

  // MARK: - ViewBuilder

  @ViewBuilder
  private func clearButtonContent() -> some View {
    Button(action: {
      withAnimation {
        inputText = ""
      }
      HapticsService.shared.shake(.light)
    }) {
      ClearIcon(font: .body)
    }
  }

  @ViewBuilder
  private func modelPickerContent() -> some View {
    Menu {
      Group {
        // Favorite models section - always first
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

        // Provider sections - always second
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

        // More (Settings) - always last
        Button {
          // TODO: Navigate to settings
        } label: {
          Label("More", systemImage: "ellipsis")
        }
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
        Image(systemName: "chevron.up.chevron.down")
          .font(.caption2)
          .foregroundStyle(selectedModel == nil ? .secondary : .primary)
      }
      .font(.caption)
    }
    .controlSize(.small)
  }

  @ViewBuilder
  private func historyPickerContent() -> some View {
    // History Messages Size Picker
    Picker("History", selection: $chatOption.contextLength) {
      ForEach(contextLengthChoices.reversed(), id: \.self) { choice in
        Text(choice.lengthString)
          .tag(choice.length)
      }
    }
    .font(.caption)
    .controlSize(.small)
    .if(chatOption.contextLength == ContextLength.zero.length) {
      $0.tint(.secondary).foregroundStyle(.secondary)
    }
    .if(chatOption.contextLength == ContextLength.infinite.length) {
      $0.tint(.orange)
    }
  }

  @ViewBuilder
  private func webSearchContent() -> some View {
    Button {
      isWebSearchEnabled.toggle()
      HapticsService.shared.shake(.light)
      SystemNotificationManager.shared.showWebSearchNotification(
        enabled: isWebSearchEnabled,
        context: notificationContext
      )
    } label: {
      Image(systemName: "globe")
        .foregroundStyle(isWebSearchEnabled ? Color.accentColor : .secondary)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  ModelContainerPreview(ModelContainer.preview) {
    VStack {
      Spacer()
      InputToolbarView(chatOption: ChatSample.greetings.option, inputText: .constant(""))
        .environmentObject(SystemNotificationContext())
    }
  }
}
