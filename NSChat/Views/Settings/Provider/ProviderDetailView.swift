import os
import SwiftData
import SwiftUI

struct ProviderDetailView: View {
  @Environment(\.modelContext) private var modelContext

  @Bindable var provider: Provider
  
  @State private var showingAddModel = false
  @State private var modelToEdit: ModelEntity?
  @State private var searchText = ""
  @State private var fetchedModels: [ModelInfo] = []
  @State private var fetchStatus: ProviderFetchStatus = .idle
   
  private var filteredModels: [ModelEntity] {
    if searchText.isEmpty {
      return provider.allModelsSorted
    }
    let filtered = provider.models.filter { model in
      model.resolvedName.localizedStandardContains(searchText) ||
        model.modelId.localizedStandardContains(searchText)
    }
    return ModelEntity.versionSort(filtered)
  }
  
  var body: some View {
    List {
      ProviderConfigurationForm(
        providerType: $provider.type,
        alias: $provider.alias,
        apiKey: $provider.apiKey,
        endpoint: $provider.endpoint,
        enabled: $provider.enabled
      )
      
      modelSection()
    }
    .animation(.default, value: filteredModels.map { $0.persistentModelID })
    .searchable(text: $searchText, prompt: "Search models")
    .navigationTitle(provider.displayName)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showingAddModel = true
        } label: {
          Label("Add Custom Model", systemImage: "plus.circle")
        }
      }
    }
    .sheet(isPresented: $showingAddModel) {
      AddCustomModelView(provider: provider)
    }
    .sheet(item: $modelToEdit) { model in
      EditModelView(model: model)
    }
    .onChange(of: fetchedModels) { _, newModels in
      if !newModels.isEmpty {
        updateModelsInDatabase(with: newModels)
      }
    }
  }
  
  @ViewBuilder
  private func modelSection() -> some View {
    Section {
      if fetchStatus != .idle {
        fetchStatusRow()
      }
      
      if filteredModels.isEmpty && searchText.isEmpty && fetchStatus == .idle {
        ContentUnavailableView {
          Label("No Models", systemImage: "cube.transparent")
        } description: {
          Text("Fetch models from the provider or add custom models")
        }
      } else {
        ForEach(filteredModels) { model in
          ModelRow(
            model: model,
            onEdit: {
              modelToEdit = model
            }
          )
        }
      }
    } header: {
      HStack {
        Text("Models (\(provider.models.count))")
        Spacer()
        if fetchStatus != .fetching {
          Button {
            fetchModels()
          } label: {
            Image(systemName: "arrow.clockwise")
              .font(.caption)
          }
        }
      }
    }
  }
  
  @ViewBuilder
  private func fetchStatusRow() -> some View {
    HStack {
      switch fetchStatus {
      case .idle:
        EmptyView()
      case .fetching:
        ProgressView()
        Text("Fetching models...")
      case .success(let count):
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
        Text("Fetched \(count) models")
      case .error(let message):
        Image(systemName: "exclamationmark.triangle.fill")
          .foregroundColor(.orange)
        Text(message)
          .font(.caption)
      }
    }
  }
  
  private func fetchModels() {
    let apiKey = provider.apiKey
    if apiKey.isEmpty {
      fetchStatus = .error("API Key is required")
      return
    }
    
    fetchStatus = .fetching
    
    Task {
      do {
        let fetcher = ModelFetcherFactory.createFetcher(for: provider.type)
        let modelInfos = try await fetcher.fetchModels(
          apiKey: apiKey,
          endpoint: provider.endpoint
        )
        
        await MainActor.run {
          fetchedModels = modelInfos
          fetchStatus = .success(modelInfos.count)
          
          AppLogger.data.info("Fetched \(modelInfos.count) models for \(provider.displayName)")
        }
      } catch {
        await MainActor.run {
          fetchStatus = .error(error.localizedDescription)
          
          AppLogger.logError(.from(
            error: error,
            operation: "Fetch models",
            component: "ProviderDetailView"
          ))
        }
      }
    }
  }
  
  private func updateModelsInDatabase(with modelInfos: [ModelInfo]) {
    let existingModels = provider.models
    
    for modelInfo in modelInfos {
      if let existingModel = existingModels.first(where: { $0.modelId == modelInfo.id && !$0.isCustom }) {
        existingModel.modelName = modelInfo.name
        existingModel.contextLength = modelInfo.contextLength
      } else {
        let newModel = ModelEntity(
          provider: provider,
          modelId: modelInfo.id,
          modelName: modelInfo.name,
          contextLength: modelInfo.contextLength
        )
        modelContext.insert(newModel)
      }
    }
    
    let modelIDs = Set(modelInfos.map { $0.id })
    let modelsToDelete = existingModels.filter { !$0.isCustom && !modelIDs.contains($0.modelId) }
    for model in modelsToDelete {
      modelContext.delete(model)
    }
    
    // Force save to ensure SwiftData updates are persisted and view refreshes
    do {
      try modelContext.save()
    } catch {
      AppLogger.logError(.from(
        error: error,
        operation: "Save models after update",
        component: "ProviderDetailView"
      ))
    }
  }
}

struct ModelRow: View {
  @Environment(\.modelContext) private var modelContext
  let model: ModelEntity
  let onEdit: () -> Void
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(model.resolvedName)
          .font(.body)
        
        HStack(spacing: 8) {
          if let contextLength = model.contextLength {
            Text("\(contextLength)k context")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
      
      Spacer()
      
      if model.isCustom {
        Image(systemName: "wrench")
          .foregroundColor(.primary)
      }
      
      if model.favorited {
        Button {
          model.favorited.toggle()
        } label: {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
        }
        .buttonStyle(.plain)
      }
    }
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      Button {
        withAnimation {
          model.favorited.toggle()
        }
      } label: {
        Label(
          model.favorited ? "Unstar" : "Star",
          systemImage: model.favorited ? "star.slash.fill" : "star.fill"
        )
      }
      .tint(.yellow)
    }
    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
      Button(role: .destructive) {
        modelContext.delete(model)
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
    .contextMenu {
      Text(model.modelId)
      
      Divider()
      
      Button {
        onEdit()
      } label: {
        Label("Edit", systemImage: "pencil")
      }
      .disabled(!model.isCustom)
      
      Button {
        withAnimation {
          model.favorited.toggle()
        }
      } label: {
        Label(
          model.favorited ? "Unfavorite" : "Favorite",
          systemImage: model.favorited ? "star.slash" : "star"
        )
      }
      
      Divider()
      
      Button(role: .destructive) {
        modelContext.delete(model)
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }
}

#Preview {
  let container = ModelContainer.preview()
  let provider = Provider(type: .openAI, alias: "My OpenAI", apiKey: "test-key")
  container.mainContext.insert(provider)
  
  return NavigationStack {
    ProviderDetailView(provider: provider)
      .modelContainer(container)
  }
}
