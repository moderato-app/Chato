// Created for Chato in 2025

import os
import SwiftData
import SwiftUI

struct ProvidersView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  
  @Query(sort: \Provider.createdAt, order: .reverse) private var providers: [Provider]
  
  @State private var showingAddProvider = false
  @State private var selectedProvider: Provider?
  
  var body: some View {
    List {
      if providers.isEmpty {
        ContentUnavailableView {
          Label("No Providers", systemImage: "cube.box")
        } description: {
          Text("Add a provider to get started")
        } actions: {
          Button("Add Provider") {
            showingAddProvider = true
          }
          .buttonStyle(.borderedProminent)
        }
      } else {
        ForEach(providers) { provider in
          NavigationLink {
            ProviderDetailView(provider: provider)
          } label: {
            ProviderRow(provider: provider)
          }
        }
        .onDelete(perform: deleteProviders)
      }
    }
    .navigationTitle("Providers")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Done") {
          dismiss()
        }
      }
        
      if !providers.isEmpty {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingAddProvider = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    }
    .sheet(isPresented: $showingAddProvider) {
      AddProviderView()
    }
  }
  
  private func deleteProviders(at offsets: IndexSet) {
    for index in offsets {
      let provider = providers[index]
      modelContext.delete(provider)
    }
  }
}

struct ProviderRow: View {
  let provider: Provider
  
  var body: some View {
    HStack {
      Image(systemName: provider.iconName)
        .foregroundColor(.accentColor)
        .frame(width: 24, height: 24)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(provider.displayName)
          .font(.body)
        
        Text("\(provider.models.count) models")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      if !provider.enabled {
        Image(systemName: "exclamationmark.triangle")
          .foregroundColor(.orange)
      }
    }
  }
}

#Preview {
  ProvidersView()
    .modelContainer(ModelContainer.preview())
}
