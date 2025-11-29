// Created for Chato in 2025

import SwiftUI
import SwiftData
import os

struct ModelSelectionView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @Query(filter: #Predicate<Provider> { $0.enabled }) private var providers: [Provider]
  @Query private var allModels: [ModelEntity]
  
  @Binding var selectedModelId: String
  @State private var searchText = ""
  
  private var favoritedModels: [ModelEntity] {
    allModels.filter { $0.favorited }.sorted { model1, model2 in
      if model1.favorited != model2.favorited {
        return model1.favorited
      }
      if model1.isCustom != model2.isCustom {
        return model1.isCustom
      }
      return model1.resolvedName < model2.resolvedName
    }
  }
  
  private var filteredModels: [ModelEntity] {
    if searchText.isEmpty {
      return allModels
    }
    return allModels.filter { model in
      model.resolvedName.localizedStandardContains(searchText) ||
      model.id.localizedStandardContains(searchText)
    }
  }
  
  private var groupedProviders: [(provider: Provider, models: [ModelEntity])] {
    let filtered = searchText.isEmpty ? allModels : filteredModels
    return filtered.groupedByProvider()
  }
  
  var body: some View {
    NavigationStack {
      List {
        if !favoritedModels.isEmpty && searchText.isEmpty {
          Section {
            ForEach(favoritedModels) { model in
              ModelSelectionRow(
                model: model,
                isSelected: model.id == selectedModelId,
                showProvider: true
              ) {
                selectModel(model)
              }
            }
          } header: {
            Label("Favorites", systemImage: "star.fill")
              .foregroundColor(.yellow)
          }
        }
        
        ForEach(groupedProviders, id: \.provider.id) { group in
          Section {
            ForEach(group.models) { model in
              ModelSelectionRow(
                model: model,
                isSelected: model.id == selectedModelId,
                showProvider: false
              ) {
                selectModel(model)
              }
            }
          } header: {
            HStack {
              Image(systemName: group.provider.iconName)
              Text(group.provider.displayName)
            }
          }
        }
        
        if !searchText.isEmpty && filteredModels.isEmpty {
          ContentUnavailableView.search
        }
        
        if providers.isEmpty && allModels.isEmpty {
          Section {
            ContentUnavailableView {
              Label("No Models Available", systemImage: "cube.box")
            } description: {
              Text("Add providers in Settings to get started")
            } actions: {
              Button("Open Settings") {
                dismiss()
              }
              .buttonStyle(.borderedProminent)
            }
          }
        }
      }
      .searchable(text: $searchText, prompt: "Search models")
      .navigationTitle("Select Model")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
  }
  
  private func selectModel(_ model: ModelEntity) {
    selectedModelId = model.id
    dismiss()
  }
}

struct ModelSelectionRow: View {
  let model: ModelEntity
  let isSelected: Bool
  let showProvider: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(model.resolvedName)
            .font(.body)
            .foregroundColor(.primary)
          
          HStack(spacing: 8) {
            if showProvider, let provider = model.provider {
              Label(provider.displayName, systemImage: provider.iconName)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            if model.isCustom {
              Label("Custom", systemImage: "wrench")
                .font(.caption2)
                .foregroundColor(.blue)
            }
            
            if let contextLength = model.contextLength {
              Text("\(contextLength)k")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
        
        Spacer()
        
        if model.favorited {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .font(.caption)
        }
        
        if isSelected {
          Image(systemName: "checkmark")
            .foregroundColor(.accentColor)
        }
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  let container = ModelContainer.preview()
  let provider = Provider(type: .openAI, alias: "OpenAI", apiKey: "test")
  container.mainContext.insert(provider)
  
  let model1 = ModelEntity(id: "gpt-4o", name: "GPT-4o", favorited: true, provider: provider)
  let model2 = ModelEntity(id: "gpt-4o-mini", name: "GPT-4o Mini", provider: provider)
  container.mainContext.insert(model1)
  container.mainContext.insert(model2)
  
  return ModelSelectionView(selectedModelId: .constant("gpt-4o"))
    .modelContainer(container)
}

