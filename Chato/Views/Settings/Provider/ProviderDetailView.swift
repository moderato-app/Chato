// Created for Chato in 2025

import SwiftUI
import SwiftData
import os

struct ProviderDetailView: View {
  @Environment(\.modelContext) private var modelContext
  
  let provider: Provider
  
  @State private var isEditing = false
  @State private var showingAddModel = false
  @State private var searchText = ""
  @State private var fetchStatus: FetchStatus = .idle
  
  private var filteredModels: [ModelEntity] {
    if searchText.isEmpty {
      return provider.allModelsSorted
    }
    return provider.models.filter { model in
      model.resolvedName.localizedStandardContains(searchText) ||
      model.id.localizedStandardContains(searchText)
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
      Section {
        HStack {
          Label {
            Text("Provider Type")
          } icon: {
            Image(systemName: provider.iconName)
              .foregroundColor(.accentColor)
          }
          Spacer()
          Text(provider.type.displayName)
            .foregroundColor(.secondary)
        }
        
        if let alias = provider.alias {
          HStack {
            Label("Alias", systemImage: "tag")
            Spacer()
            Text(alias)
              .foregroundColor(.secondary)
          }
        }
        
        if let endpoint = provider.endpoint {
          HStack {
            Label("Endpoint", systemImage: "network")
            Spacer()
            Text(endpoint)
              .foregroundColor(.secondary)
              .lineLimit(1)
              .truncationMode(.middle)
          }
        }
      } header: {
        Text("Information")
      }
      
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
            Button("Fetch") {
              fetchModels()
            }
            .font(.caption)
          }
        }
      }
    }
    .searchable(text: $searchText, prompt: "Search models")
    .navigationTitle(provider.displayName)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Menu {
          Button {
            isEditing = true
          } label: {
            Label("Edit Provider", systemImage: "pencil")
          }
          
          Button {
            showingAddModel = true
          } label: {
            Label("Add Custom Model", systemImage: "plus.circle")
          }
          
          Button {
            fetchModels()
          } label: {
            Label("Fetch Models", systemImage: "arrow.clockwise")
          }
          .disabled(fetchStatus == .fetching)
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
    .sheet(isPresented: $isEditing) {
      EditProviderView(provider: provider)
    }
    .sheet(isPresented: $showingAddModel) {
      AddCustomModelView(provider: provider)
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
    guard let apiKey = provider.apiKey else {
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
      if let existingModel = existingModels.first(where: { $0.id == modelInfo.id && !$0.isCustom }) {
        existingModel.name = modelInfo.name
        existingModel.contextLength = modelInfo.contextLength
      } else {
        let newModel = ModelEntity(
          id: modelInfo.id,
          name: modelInfo.name,
          contextLength: modelInfo.contextLength,
          provider: provider
        )
        modelContext.insert(newModel)
      }
    }
    
    let modelIDs = Set(modelInfos.map { $0.id })
    let modelsToDelete = existingModels.filter { !$0.isCustom && !modelIDs.contains($0.id) }
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

