import SwiftUI
import SwiftData
import os

struct AddProviderView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @State private var selectedType: ProviderType = .openAI
  @State private var alias: String = ""
  @State private var apiKey: String = ""
  @State private var endpoint: String = ""
  @State private var enabled: Bool = true
  @State private var fetchedModels: [ModelInfo] = []
  @State private var fetchStatus: ProviderFetchStatus = .idle
  
  private var displayName: String {
    if !alias.isEmpty {
      return alias
    }
    return selectedType.displayName
  }
  
  var body: some View {
    NavigationStack {
      List {
        ProviderConfigurationForm(
          providerType: $selectedType,
          alias: $alias,
          apiKey: $apiKey,
          endpoint: $endpoint,
          enabled: $enabled
        )
        
        ModelListSection(
          providerType: selectedType,
          apiKey: apiKey,
          endpoint: endpoint,
          fetchedModels: $fetchedModels,
          fetchStatus: $fetchStatus
        )
      }
      .navigationTitle("Add Provider")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveProvider()
          }
          .disabled(apiKey.isEmpty)
        }
      }
    }
  }
  
  private func saveProvider() {
    let provider = Provider(
      type: selectedType,
      alias: alias,
      apiKey: apiKey,
      endpoint: endpoint,
      enabled: enabled
    )
    
    modelContext.insert(provider)
    
    for modelInfo in fetchedModels {
      let model = ModelEntity(
        provider: provider,
        modelId: modelInfo.id,
        modelName: modelInfo.name,
        contextLength: modelInfo.contextLength
      )
      modelContext.insert(model)
    }
    
    AppLogger.data.info("Added new provider: \(provider.displayName) with \(fetchedModels.count) models")
    
    dismiss()
  }
}

#Preview {
  AddProviderView()
    .modelContainer(ModelContainer.preview())
}


#Preview {
  AddProviderView()
    .modelContainer(ModelContainer.preview())
}

