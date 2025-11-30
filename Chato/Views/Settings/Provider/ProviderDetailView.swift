import os
import SwiftData
import SwiftUI

struct ProviderDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  @Bindable var provider: Provider
  
  @State private var showingAddModel = false
  @State private var searchText = ""
  @State private var fetchStatus: FetchStatus = .idle
   
  private var filteredModels: [ModelEntity] {
    if searchText.isEmpty {
      return provider.allModelsSorted
    }
    return provider.models.filter { model in
      model.resolvedName.localizedStandardContains(searchText) ||
        model.modelId.localizedStandardContains(searchText)
    }.sorted { model1, model2 in
      if model1.favorited != model2.favorited {
        return model1.favorited
      }
      if model1.isCustom != model2.isCustom {
        return model1.isCustom
      }
      return model1.resolvedName < model2.resolvedName
    }
  }
  
  var body: some View {
    List {
      editSections()
      modelSection()
    }
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
  }
  
  @ViewBuilder
  private func editSections() -> some View {
    Section {
      Picker("Provider Type", selection: $provider.type) {
        ForEach(ProviderType.allCases, id: \.self) { type in
          Label {
            Text(type.displayName)
          } icon: {
            Image(systemName: type.iconName)
          }
          .tag(type)
        }
      }
    } header: {
      Text("Type")
    }
    
    Section {
      TextField("Alias (Optional)", text: $provider.alias)
      
      TextField("API Key", text: $provider.apiKey)
        .textContentType(.password)
      
      TextField("Endpoint (Optional)", text: $provider.endpoint)
        .textContentType(.URL)
        .autocapitalization(.none)
    } header: {
      Text("Configuration")
    } footer: {
      Text("Leave endpoint empty to use default")
    }
    
    Section {
      Toggle("Enabled", isOn: $provider.enabled)
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
          ModelRow(model: model)
        }
      }
    } header: {
      HStack {
        Text("Models (\(provider.models.count))")
        Spacer()
        if fetchStatus != .fetching {
          Button("Refresh") {
            fetchModels()
          }
          .font(.caption)
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
          updateModels(with: modelInfos)
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
  
  private func updateModels(with modelInfos: [ModelInfo]) {
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
          contextLength: modelInfo.contextLength,
        )
        modelContext.insert(newModel)
      }
    }
    
    let modelIDs = Set(modelInfos.map { $0.id })
    let modelsToDelete = existingModels.filter { !$0.isCustom && !modelIDs.contains($0.modelId) }
    for model in modelsToDelete {
      modelContext.delete(model)
    }
  }
}

struct ModelRow: View {
  let model: ModelEntity
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(model.resolvedName)
          .font(.body)
        
        HStack(spacing: 8) {
          if model.isCustom {
            Label("Custom", systemImage: "wrench")
              .font(.caption2)
              .foregroundColor(.blue)
          }
          
          if let contextLength = model.contextLength {
            Text("\(contextLength)k context")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }
      }
      
      Spacer()
      
      Button {
        model.favorited.toggle()
      } label: {
        Image(systemName: model.favorited ? "star.fill" : "star")
          .foregroundColor(model.favorited ? .yellow : .gray)
      }
      .buttonStyle(.plain)
    }
  }
}

private enum FetchStatus: Equatable {
  case idle
  case fetching
  case success(Int)
  case error(String)
  
  static func == (lhs: FetchStatus, rhs: FetchStatus) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle), (.fetching, .fetching):
      return true
    case (.success(let l), .success(let r)):
      return l == r
    case (.error(let l), .error(let r)):
      return l == r
    default:
      return false
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
