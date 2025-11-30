// Created for Chato in 2025

import os
import SwiftData
import SwiftUI

struct ModelSelectionView: View {
  @Environment(\.dismiss) private var dismiss
  
  @Query(filter: #Predicate<Provider> { $0.enabled }) private var providers: [Provider]
  @Query private var allModels: [ModelEntity]
  
  @Bindable var chatOption: ChatOption
  @State private var searchText = ""
  @State private var expandedProviders: Set<PersistentIdentifier> = []
  @State private var favoritesExpanded = true
  
  var body: some View {
    ModelSelectionContent(
      chatOption: chatOption,
      providers: providers,
      allModels: allModels,
      searchText: $searchText,
      expandedProviders: $expandedProviders,
      favoritesExpanded: $favoritesExpanded,
      dismiss: dismiss
    )
  }
}

struct ModelSelectionContent: View {
  @Bindable var chatOption: ChatOption
  let providers: [Provider]
  let allModels: [ModelEntity]
  @Binding var searchText: String
  @Binding var expandedProviders: Set<PersistentIdentifier>
  @Binding var favoritesExpanded: Bool
  let dismiss: DismissAction
  
  private var favoritedModels: [ModelEntity] {
    let filtered = allModels.filter { $0.favorited }
    return ModelEntity.smartSort(filtered)
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
    ScrollViewReader { proxy in
      List {
        favoritesSection
        providerSections
        emptyStateViews
      }
      .searchable(text: $searchText, prompt: "Search models")
      .navigationTitle("Select Model")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .onAppear {
        expandInitialSections()
        scrollToSelectedModel(proxy: proxy)
      }
    }
  }
  
  @ViewBuilder
  private var favoritesSection: some View {
    if !favoritedModels.isEmpty && searchText.isEmpty {
      favoritesSectionContent
    }
  }
  
  private var favoritesSectionContent: some View {
    DisclosureGroup(
      isExpanded: $favoritesExpanded
    ) {
      ForEach(favoritedModels) { model in
        ModelSelectionRow(
          model: model,
          isSelected: model.id == chatOption.model?.id,
          showProvider: true
        ) {
          selectModel(model)
        }
        .id(model.id)
      }
    } label: {
      Label("Favorites", systemImage: "star.fill")
        .foregroundColor(.yellow)
    }
  }
  
  @ViewBuilder
  private var providerSections: some View {
    ForEach(groupedProviders, id: \.provider.id) { group in
      providerSection(for: group)
    }
  }
  
  private func providerSection(for group: (provider: Provider, models: [ModelEntity])) -> some View {
    DisclosureGroup(
      isExpanded: providerBinding(for: group.provider.id)
    ) {
      ForEach(group.models) { model in
        ModelSelectionRow(
          model: model,
          isSelected: model.id == chatOption.model?.id,
          showProvider: false
        ) {
          selectModel(model)
        }
        .id(model.id)
      }
    } label: {
      HStack {
        Image(systemName: group.provider.iconName)
        Text(group.provider.displayName)
      }
    }
    .tint(.secondary)
  }
  
  private func providerBinding(for providerId: PersistentIdentifier) -> Binding<Bool> {
    Binding(
      get: { expandedProviders.contains(providerId) },
      set: { isExpanded in
        if isExpanded {
          expandedProviders.insert(providerId)
        } else {
          expandedProviders.remove(providerId)
        }
      }
    )
  }
  
  @ViewBuilder
  private var emptyStateViews: some View {
    if !searchText.isEmpty && filteredModels.isEmpty {
      ContentUnavailableView.search
    }
    
    if providers.isEmpty && allModels.isEmpty {
      noModelsView
    }
  }
  
  private var noModelsView: some View {
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
  
  private func expandInitialSections() {
    guard expandedProviders.isEmpty else { return }
    
    // Check if selected model exists and is not in favorites
    if let selectedModel = chatOption.model,
       !favoritedModels.contains(where: { $0.id == selectedModel.id }) {
      // Find and expand only the provider containing the selected model
      if let providerGroup = groupedProviders.first(where: { group in
        group.models.contains(where: { $0.id == selectedModel.id })
      }) {
        expandedProviders = [providerGroup.provider.id]
      }
    }
    // Otherwise, all providers remain collapsed (only favorites is expanded)
  }
  
  private func scrollToSelectedModel(proxy: ScrollViewProxy) {
    guard let selectedModel = chatOption.model else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      withAnimation {
        proxy.scrollTo(selectedModel.id, anchor: .center)
      }
    }
  }
  
  private func selectModel(_ model: ModelEntity) {
    chatOption.model = model
  }
}

struct ModelSelectionRow: View {
  let model: ModelEntity
  let isSelected: Bool
  let showProvider: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        if model.favorited {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .font(.caption)
        }
        
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
        
        if isSelected {
          Image(systemName: "checkmark")
            .foregroundColor(.accentColor)
        }
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}
