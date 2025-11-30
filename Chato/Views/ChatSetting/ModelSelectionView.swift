// Created for Chato in 2025

import SwiftUI
import SwiftData
import os

struct ModelSelectionView: View {
  @Environment(\.dismiss) private var dismiss
  
  @Query(filter: #Predicate<Provider> { $0.enabled }) private var providers: [Provider]
  @Query private var allModels: [ModelEntity]
  
  @Bindable var chatOption: ChatOption
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
      model.modelId.localizedStandardContains(searchText)
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
                isSelected: model.id == chatOption.model?.id,
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
                isSelected: model.id == chatOption.model?.id,
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
    chatOption.model = model
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
            if showProvider {
              Label(model.provider.displayName, systemImage: model.provider.iconName)
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
