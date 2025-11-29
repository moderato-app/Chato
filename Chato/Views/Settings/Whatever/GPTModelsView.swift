// Created for Chato in 2024

import Foundation
import SwiftData
import SwiftUI
import os

struct GPTModelsView: View {
  private static let sortOrder = [SortDescriptor(\ModelModel.pos, order: .reverse)]

  @Environment(\.modelContext) private var modelContext
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.isSearching) private var isSearching
  @Environment(\.aiClient) private var aiClient

  @State private var isDeleteConfirmPresented: Bool = false
  @State private var isMultiDeleteConfirmPresented: Bool = false
  @State private var modelToDelete: ModelModel?

  @State private var editMode: EditMode = .inactive
  @State private var selectedItemIDs = Set<String>()
  @State private var fetchStatus: FetchStatus = .idle

  @Query(sort: \ModelModel.pos, order: .reverse) var models: [ModelModel]
//  let models: [ModelModel] = ModelModel.samples

  @Binding var selectedModelID: String
  let searchString: String

  init(_ searchString: String = "", selectedModelID: Binding<String>) {
    _selectedModelID = selectedModelID
    self.searchString = searchString
    _models = Query(filter: #Predicate {
      if searchString.isEmpty {
        return true
      } else {
        return ($0.name?.localizedStandardContains(searchString) ?? false) || ($0.modelId.localizedStandardContains(searchString))
      }
    }, sort: Self.sortOrder)
  }

  var modelsByProvider: [String: [ModelModel]] {
    Dictionary(grouping: models, by: \.provider)
  }

  var sortedModelsByProvider: [(key: String, value: [ModelModel])] {
    modelsByProvider
      .mapValues { $0.sorted { $0.resolvedName < $1.resolvedName } }
      .sorted {
        if $0.value.count == $1.value.count {
          return $0.key < $1.key
        } else {
          return $0.value.count > $1.value.count
        }
      }
  }

  var body: some View {
    main()
      .toolbar {
        toolbarItems()
      }
  }

  @ViewBuilder
  func main() -> some View {
    List(selection: $selectedItemIDs) {
      if fetchStatus != .idle || models.isEmpty {
        fetchView()
      }
      modelsSection()
    }
    .animation(.default, value: models.count)
    .animation(.default, value: fetchStatus)
    .environment(\.editMode, $editMode)
    .onAppear {
      AppLogger.ui.debug("modelsByProvider count \(modelsByProvider.count)")

      AppLogger.ui.debug("models count \(models.count)")
    }
  }

  @ToolbarContentBuilder
  func toolbarItems() -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      HStack {
        Button("Fetch") {
          fetchModels()
        }.disabled(fetchStatus == .fetching)
//        if !models.isEmpty {
//          EditButton()
//        }
      }
    }
  }

  @ViewBuilder
  func modelsSection() -> some View {
    ForEach(sortedModelsByProvider, id: \.key) { provider, models in
      Section {
        ForEach(models, id: \.modelId) { model in
          ModelRowView(model: model)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button(role: .destructive) {
                modelToDelete = model
                isDeleteConfirmPresented.toggle()
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
        }
        .onMove(perform: onMove)
      } header: {
        Text(sectionName(provider, models.count))
          .font(.title2).fontWeight(.bold)
      }
      .textCase(.none)
    }
    .confirmationDialog(
      modelToDelete?.name ?? "",
      isPresented: $isDeleteConfirmPresented,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        if let model = modelToDelete {
          modelContext.delete(model)
        }
      }
    } message: {
      Text("This model will be deleted.")
    }
    .confirmationDialog(
      "Delete \(selectedItemIDs.count) models",
      isPresented: $isMultiDeleteConfirmPresented,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        removeItems(selectedItemIDs)
        selectedItemIDs = .init()
      }
    } message: {
      Text("\(selectedItemIDs.count) models will be deleted.")
    }
  }

  private func sectionName(_ provider: String, _ count: Int) -> String {
    if provider == "" {
      ""
    } else {
      if count > 5 {
        "\(provider.capitalized)(\(count))"
      } else {
        "\(provider.capitalized)"
      }
    }
  }

  private func removeItems(_ selectedItemIDs: Set<String>) {
    for id in selectedItemIDs {
      if let modelToDelete = models.first(where: { $0.modelId == id }) {
        modelContext.delete(modelToDelete)
      }
    }
  }

  func onMove(from source: IndexSet, to destination: Int) {
    var updatedItems = models
    updatedItems.move(fromOffsets: source, toOffset: destination)
    updatedItems.reIndex()
  }
}

private enum FetchStatus: Equatable {
  case idle
  case fetching
  case fetched(count: Int)
  case failed(Error)

  static func == (lhs: FetchStatus, rhs: FetchStatus) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle),
         (.fetching, .fetching):
      return true
    case (.fetched(let lhsCount), .fetched(let rhsCount)):
      return lhsCount == rhsCount
    case (.failed(let lhsError as NSError), .failed(let rhsError as NSError)):
      return lhsError == rhsError
    default:
      return false
    }
  }
}

extension GPTModelsView {
  @ViewBuilder
  func fetchView() -> some View {
    HStack {
      Spacer()
      switch fetchStatus {
      case .idle:
        Button("Fetch Models") {
          fetchModels()
        }.buttonStyle(.borderedProminent)
      case .fetching:
        ProgressView("Fetching models...")
      case .fetched(let count):
        Text("✅ Fetched \(count) models")
      case .failed(let error):
        VStack {
          Button("Retry") {
            fetchModels()
          }.buttonStyle(.borderedProminent)
          Text("⚠️ Failed to fetch models: \(error.localizedDescription)")
        }
      }
      Spacer()
    }
    .animation(.default, value: fetchStatus)
  }

  func fetchModels() {
    fetchStatus = .fetching
    Task {
      do {
        let ms = try await aiClient.fetchModels()
        await MainActor.run {
          fetchStatus = .fetched(count: ms.count)
          if ms.count > 0 {
            modelContext.updateModels(models: ms)
          }
        }
      } catch {
        await MainActor.run {
          fetchStatus = .failed(error)
        }
      }
    }
  }
}

#Preview {
  @Previewable @State var searchString = ""
  LovelyPreview {
    NavigationStack {
      GPTModelsView(searchString, selectedModelID: .constant(""))
        .searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always))
    }
  }
}
