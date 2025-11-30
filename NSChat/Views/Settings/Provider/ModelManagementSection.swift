import SwiftUI
import os

struct ModelManagementSection: View {
  let providerType: ProviderType
  let apiKey: String
  let endpoint: String
  let providerDisplayName: String
  
  @Binding var fetchedModels: [ModelInfo]
  @Binding var fetchStatus: ProviderFetchStatus
  @State private var searchText = ""
  
  private var filteredModels: [ModelInfo] {
    if searchText.isEmpty {
      return fetchedModels.sorted { $0.name < $1.name }
    }
    return fetchedModels.filter { model in
      model.name.localizedStandardContains(searchText) ||
        model.id.localizedStandardContains(searchText)
    }.sorted { $0.name < $1.name }
  }
  
  var body: some View {
    Section {
      if fetchStatus != .idle {
        fetchStatusRow()
      }
      
      if fetchedModels.isEmpty && searchText.isEmpty && fetchStatus == .idle {
        ContentUnavailableView {
          Label("No Models", systemImage: "cube.transparent")
        } description: {
          Text("Fetch models from the provider")
        }
      } else {
        ForEach(filteredModels, id: \.id) { model in
          ModelInfoRow(model: model)
        }
      }
    } header: {
      HStack {
        Text("Models (\(fetchedModels.count))")
        Spacer()
        if fetchStatus != .fetching {
          Button("Fetch") {
            fetchModels()
          }
          .font(.caption)
        }
      }
    }
    .searchable(text: $searchText, prompt: "Search models")
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
    if apiKey.isEmpty {
      fetchStatus = .error("API Key is required")
      return
    }
    
    fetchStatus = .fetching
    
    Task {
      do {
        let fetcher = ModelFetcherFactory.createFetcher(for: providerType)
        let modelInfos = try await fetcher.fetchModels(
          apiKey: apiKey,
          endpoint: endpoint
        )
        
        await MainActor.run {
          fetchedModels = modelInfos
          fetchStatus = .success(modelInfos.count)
          
          AppLogger.data.info("Fetched \(modelInfos.count) models for \(providerDisplayName)")
        }
      } catch {
        await MainActor.run {
          fetchStatus = .error(error.localizedDescription)
          
          AppLogger.logError(.from(
            error: error,
            operation: "Fetch models",
            component: "ModelManagementSection"
          ))
        }
      }
    }
  }
}

struct ModelInfoRow: View {
  let model: ModelInfo
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(model.name)
        .font(.body)
      
      if let contextLength = model.contextLength {
        Text("\(contextLength)k context")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }
}

enum ProviderFetchStatus: Equatable {
  case idle
  case fetching
  case success(Int)
  case error(String)
  
  static func == (lhs: ProviderFetchStatus, rhs: ProviderFetchStatus) -> Bool {
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

