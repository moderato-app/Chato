import os
import SwiftData
import SwiftUI

enum ProviderViewMode {
  case Add, Edit
}

struct ProviderView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @Bindable var provider: Provider
  let mode: ProviderViewMode

  @State private var searchText = ""
  @State private var modelToEdit: ModelEntity?
  @State private var showingAddModel = false

  var body: some View {
    CondNavigationStack(mode == .Add) {
      list
    }
  }

  @ViewBuilder
  var list: some View {
    List {
      ProviderConfigurationForm(provider: provider, mode: mode)

      ModelListSection(
        provider: provider,
        searchText: $searchText,
        modelToEdit: $modelToEdit,
        showingAddModel: $showingAddModel
      )
    }
    .animation(.default, value: provider.models.map { $0.persistentModelID })
    .searchable(text: $searchText)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(title)
    .toolbar {
      if mode == .Add {
        toolbar
      }
    }
    .onDisappear {
      if mode == .Edit {
        try? modelContext.save()
      }
    }
    .sheet(isPresented: $showingAddModel) {
      AddCustomModelView(provider: provider)
    }
    .sheet(item: $modelToEdit) { model in
      EditModelView(model: model)
    }
  }

  var title: String {
    switch mode {
    case .Add:
      return "Add Provider"
    case .Edit:
      return provider.displayName
    }
  }

  @ToolbarContentBuilder
  var toolbar: some ToolbarContent {
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

  private func saveProvider() {
    modelContext.insert(provider)
    AppLogger.data.info("Added new provider: \(provider.displayName) with \(provider.models.count) models")
    dismiss()
  }
}
