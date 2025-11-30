import SwiftUI

extension SettingView {
  @ViewBuilder
  var providersSection: some View {
    Section {
      if providers.isEmpty {
        ContentUnavailableView {
          Label("No Providers", systemImage: "cube.box")
        } description: {
          Text("Add a provider to get started")
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
      
      Button {
        showingAddProvider = true
      } label: {
        Label("Add Provider", systemImage: "plus.circle.fill")
          .foregroundColor(.accentColor)
      }
    } header: {
      Text("AI Providers")
    }
    .textCase(.none)
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

