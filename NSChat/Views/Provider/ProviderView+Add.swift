import os
import SwiftData
import SwiftUI

struct AddProviderView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @Bindable var provider: Provider = .init(type: .openAI)
  @State private var searchText = ""

  var body: some View {
    NavigationStack {
      List {
        ProviderConfigurationForm(
          providerType: $provider.type,
          alias: $provider.alias,
          apiKey: $provider.apiKey,
          endpoint: $provider.endpoint,
          enabled: $provider.enabled
        )
        
        ModelListSection(provider: provider,searchText: $searchText)
      }
      .navigationBarTitleDisplayMode(.inline)
      .searchable(text: $searchText)
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
          .disabled(provider.apiKey.isEmpty)
        }
      }
      .navigationTitle("Add Provider")
    }
  }
  
  private func saveProvider() {
    modelContext.insert(provider)
    AppLogger.data.info("Added new provider: \(provider.displayName) with \(provider.models.count) models")
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
