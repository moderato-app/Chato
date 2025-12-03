import os
import SwiftData
import SwiftUI

struct AddProviderView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @Bindable var provider: Provider
  
  @State private var searchText = ""
  @State private var modelToEdit: ModelEntity?
  @State private var showingAddModel = false

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
        
        ModelListSection(
          provider: provider,
          searchText: $searchText,
          modelToEdit: $modelToEdit,
          showingAddModel: $showingAddModel
        )
      }
      .animation(.default, value: provider.models.map { $0.persistentModelID })
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
          .disabled(provider.apiKey.isEmpty)
        }
      }
      .searchable(text: $searchText)
      .sheet(isPresented: $showingAddModel) {
        AddCustomModelView(provider: provider)
      }
      .sheet(item: $modelToEdit) { model in
        EditModelView(model: model)
      }
    }
  }
  
  private func saveProvider() {
    modelContext.insert(provider)
    AppLogger.data.info("Added new provider: \(provider.displayName) with \(provider.models.count) models")
    dismiss()
  }
}
