import SwiftUI

extension SettingView {
  @ViewBuilder
  var providersSection: some View {
    Section {
      if providers.isEmpty {
        EmptyProviderCard {
          showingAddProvider = true
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
        
        Button {
          showingAddProvider = true
        } label: {
          HStack {
            Image(systemName: "plus.circle.fill")
            Text("Add Provider")
          }
        }
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
      VStack(alignment: .leading, spacing: 4) {
        Text(provider.displayName)
          .font(.body)
          .foregroundColor(provider.enabled ? .primary : .secondary)
        
        Text("\(provider.models.count) models")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
    }
  }
}

